-- ミサイルが設定した距離に近づくと艦艇からフレアを発射するスクリプト
-- 現在のDCSには対艦ミサイルを惑わすシステムは存在しないため回避効果なし
-- あくまで雰囲気を出すためのスクリプト

function decoySystem()

    local _COALITIONSIDERED = 1
    local _COALITIONSIDEBLUE = 2
    local _ANTISHIPMISSILE = 4
    local _CRUISEMISSILE = 5
    local _OTHERISSILE = 6

    -- 挙動調整用
    local _OPARATIONALTARGETKEYWORD = "flare" -- この文字がユニット名に含まれていると対象になる
    local _REPETATIONTIME = 7 -- 何秒おきにフレアを撒くか
    local _FLARELAUNCHDISTANCE = 6000 -- ミサイルが何km近づいたらフレアを撒くか
    local _FLAREVOLUME = 10 -- フレアを撒く量

    local _obj = {}
    local _missileList = {}

    function _obj:onEvent( event )
        
        if event.id == world.event.S_EVENT_SHOT then
            
            --local _weapon = event.weapon
            if event.weapon:getDesc().missileCategory == _ANTISHIPMISSILE
                or  event.weapon:getDesc().missileCategory == _CRUISEMISSILE
                or  event.weapon:getDesc().missileCategory == _OTHERISSILE then
                    
                table.insert( _missileList, event.weapon )

            end

        end
    end

    function _obj:launchDecoy()

        -- 対象を取得
        -- 最初はRed軍に対して処理、次にBlue軍の処理を行う
        local _unitList = {}

        for _coalitionSideNum = _COALITIONSIDERED, _COALITIONSIDEBLUE do

            _unitList = getOparationalTargetUnits( _coalitionSideNum )

            -- フレアを発射するか判断
            judgeLaunchFlare( _unitList );

        end

        timer.scheduleFunction( self.launchDecoy, self, timer.getTime() + _REPETATIONTIME )

    end

    -- 対象グループを取得
    function getOparationalTargetUnits( _coalitionSideNum )

        local _oparationalTargetUnitList = {}

        for _i, _grp in pairs( coalition.getGroups( _coalitionSideNum ) ) do

            for _, _unit in pairs( _grp:getUnits() ) do

                if string.find( _unit:getName(), _OPARATIONALTARGETKEYWORD ) then

                    table.insert( _oparationalTargetUnitList, _unit )

                end

            end

        end

        return _oparationalTargetUnitList

    end

    -- フレアを発射するか判断
    function judgeLaunchFlare( _unitList )

        -- ユニット毎にミサイルが接近していないか判断
        for _, _unit in pairs( _unitList ) do

            local _launchFlareFlag = false

            for _, _missile in pairs( _missileList ) do

                if isEnemyMissile( _unit, _missile ) -- 敵のミサイルか
                    and isHot( _unit, _missile ) -- 接近中か
                    and isExistMissileInSettingRange( _unit, _missile ) -- 設定された距離を割っているか
                    then

                    _launchFlareFlag = true

                    break

                end

            end
            
            -- フレア放出
            if _launchFlareFlag then

                launchFlare( _unit )

            end

        end

    end

    -- 敵のミサイルか
    function isEnemyMissile( _unit, _missile )

        -- 念のための存在チェック
        if not _unit:isExist() or not _missile:isExist() then

            return false
        
        end

        if _unit:getCoalition() == _missile:getCoalition() then

            return false

        else

            return true

        end

    end

    -- ミサイルが一定以内に存在するか
    function isExistMissileInSettingRange( _unit, _missile ) 

        -- 念のための存在チェック
        if not _unit:isExist() or not _missile:isExist() then

            return false

        end

        -- ユニットとミサイルの距離を計算
        local _unitPosition = _unit:getPoint()
        local _missilePosition = _missile:getPoint()

        local _distance = math.sqrt((_unitPosition.x - _missilePosition.x)^2 + (_unitPosition.y - _missilePosition.y)^2 + (_unitPosition.z - _missilePosition.z)^2)
        
        -- 設定した距離を下回っているか
        if _distance < _FLARELAUNCHDISTANCE then

            return true

        else

            return false

        end

    end

    -- ミサイルは接近中か
    function isHot( _unit, _missile )

        -- 念のための存在チェック
        if not _unit:isExist() or not _missile:isExist() then

            return false

        end

        local _unitPosition = _unit:getPoint()
        local _missilePosition = _missile:getPoint()
        local _missileVelocity = _missile:getVelocity()
    
        local _hotXFlag = false
    
        if _missileVelocity.x >=0 then
            if _missilePosition.x < _unitPosition.x then
                _hotXFlag = true
            end
        else
            if _missilePosition.x > _unitPosition.x then
                _hotXFlag = true
            end
        end
            
        if _hotXFlag then
            if _missileVelocity.z >=0 then
                if _missilePosition.z < _unitPosition.z then
                    return true
                end
            else
                if _missilePosition.z > _unitPosition.z then
                    return true
                end
            end
        end

        return false
    end

    -- フレアを放出
    function launchFlare( _unit )

        -- 念のための存在チェック
        if _unit:isExist() then
            local _unitPos = _unit:getPosition()
            local _headingRad = math.atan2(_unitPos.x.z, _unitPos.x.x)
            local _headingDeg = math.deg(_headingRad) * ( -1 ) -- -1を掛けないと向きが合わないため

            for _i = 1, _FLAREVOLUME do

                trigger.action.signalFlare(_unit:getPoint() , 1 , math.rad( _headingDeg + 45) )
                trigger.action.signalFlare(_unit:getPoint() , 1 , math.rad( _headingDeg + 30) )
                trigger.action.signalFlare(_unit:getPoint() , 1 , math.rad( _headingDeg + 15) )
                trigger.action.signalFlare(_unit:getPoint() , 1 , math.rad( _headingDeg - 45) )
                trigger.action.signalFlare(_unit:getPoint() , 1 , math.rad( _headingDeg - 30) )
                trigger.action.signalFlare(_unit:getPoint() , 1 , math.rad( _headingDeg - 15) )

            end
            --trigger.action.signalFlare(_unit:getPoint() , 1 , math.atan2(_unitPos.x.z, _unitPos.x.x) - 45 )
        end

    end

    return _obj
end

_instance = decoySystem()
world.addEventHandler(_instance)
_instance:launchDecoy()