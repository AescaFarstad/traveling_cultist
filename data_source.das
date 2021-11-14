require model

let BAN_RECT = float4(0, 0, 220, 250)

let levels <-[[LevelSetting[6]
                [[LevelSetting id=0, seed=int4(1, 2, 3, 9), knownLength=4194.0, density=0.00004, p_factor=9, minDst=50.0, timeLimit=50]];
                [[LevelSetting id=1, seed=int4(1, 2, 3, 4), knownLength=5696.0, density=0.00008, p_factor=7, minDst=40.0, timeLimit=70]];
                [[LevelSetting id=2, seed=int4(1, 2, 3, 4), knownLength=7316.0, density=0.00015, p_factor=3, minDst=30.0, timeLimit=150]];
                [[LevelSetting id=3, seed=int4(),           knownLength=.0, density=0.00004, p_factor=5, minDst=50.0, timeLimit=50]];
                [[LevelSetting id=4, seed=int4(),           knownLength=.0, density=0.00008, p_factor=7, minDst=40.0, timeLimit=70]];
                [[LevelSetting id=5, seed=int4(),           knownLength=.0, density=0.00025, p_factor=4, minDst=25.0, timeLimit=200]]
                ]]
