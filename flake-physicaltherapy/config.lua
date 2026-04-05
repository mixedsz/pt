Config = {}

Config.Distance = 2.0
Config.System = 'ox_lib' -- Options: 'ox_target', 'qb-target', 'ox_lib'
Config.EMSJobs = {'ambulance'} -- Add EMS jobs here
Config.EMSCount = 1 -- Minimum number of EMS required to use therapy
Config.CrutchSystem = 'wasabi' -- Only 'wasabi' system is now supported
Config.Cooldown = 300 -- Cooldown in seconds (300 = 5 minutes) before player can use therapy again

Config.TherapyLocations = {
    Pillbox = {
        coords = vec4(318.9512, -589.0149, 43.2841, 341.6656),
        cost = 500,
        showBlip = true, -- Whether to show a blip on the map for this location
        ped = {
            model = 's_m_m_doctor_01',
            coords = vec4(319.1278, -588.3556, 43.2841, 160.5713),
        },
        steps = {
            {
                coords = vec4(322.3745, -592.3754, 43.2841, 68.9359),
                progress = {
                    duration = 20000,
                    label = "Leg Stretching...",
                    canCancel = false,
                    disable = { move = true, combat = true },
                    anim = {
                        dict = "mini@triathlon",
                        clip = "idle_e",
                        flag = 7,
                    },
                },
            },
            {
                coords = vec4(319.3133, -593.7554, 43.2841, 344.1032),
                progress = {
                    duration = 20000,
                    label = "Arm Stretching...",
                    canCancel = false,
                    disable = { move = true, combat = true },
                    anim = {
                        dict = "mini@triathlon",
                        clip = "idle_f",
                        flag = 7,
                    },
                },
            },
            {
                coords = vec4(316.1853, -592.1685, 43.2841, 333.1860),
                progress = {
                    duration = 20000,
                    label = "Exercising...",
                    canCancel = false,
                    disable = { move = true, combat = true },
                    anim = {
                        dict = "timetable@reunited@ig_2",
                        clip = "jimmy_getknocked",
                        flag = 7,
                    },
                },
            },
        },
    },
    SandyShores = {
        coords = vec4(1839.5, 3673.2, 34.3, 210.0),
        cost = 400,
        showBlip = false, -- Whether to show a blip on the map for this location
        ped = {
            model = 's_m_m_doctor_01',
            coords = vec4(1839.5, 3673.2, 34.3, 30.0),
        },
        steps = {
            {
                coords = vec4(1842.3, 3675.8, 34.3, 120.0),
                progress = {
                    duration = 20000,
                    label = "Leg Exercises...",
                    canCancel = false,
                    disable = { move = true, combat = true },
                    anim = {
                        dict = "mini@triathlon",
                        clip = "idle_e",
                        flag = 7,
                    },
                },
            },
            {
                coords = vec4(1840.1, 3677.5, 34.3, 210.0),
                progress = {
                    duration = 20000,
                    label = "Arm Stretching...",
                    canCancel = false,
                    disable = { move = true, combat = true },
                    anim = {
                        dict = "mini@triathlon",
                        clip = "idle_f",
                        flag = 7,
                    },
                },
            },
            {
                coords = vec4(1837.2, 3675.1, 34.3, 300.0),
                progress = {
                    duration = 20000,
                    label = "Balance Training...",
                    canCancel = false,
                    disable = { move = true, combat = true },
                    anim = {
                        dict = "timetable@reunited@ig_2",
                        clip = "jimmy_getknocked",
                        flag = 7,
                    },
                },
            },
        },
    },
}