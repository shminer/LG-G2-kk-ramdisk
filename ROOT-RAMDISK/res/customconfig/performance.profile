stweaks_boot_control=yes
oc_controller=ultra
hotplug=intelli
cpus_boosted=2
eco_mode=all
msm_thermal=msm_temp
enabled=on
core_limit_temp_degC=85
limit_temp_degC=70
default_cpu_gov=ondemand
cpu_boost_freq=1728000
ondemand_slowup=0
cortexbrain_cpu=on
cpu_max_freq=2803200
cpu_min_freq=300000
<<<<<<< HEAD
min_pwrlevel=4
max_pwrlevel=1
max_gpuclk=450000000
read_ahead_kb=2048
scheduler=fiops
sleep_scheduler=fiops
cortexbrain_cpu=off
=======
msm_thermal=msm_temp
enabled=off
core_limit_temp_degC=75
limit_temp_degC=75
hotplug=msm_hotplug
cpus_boosted=1
eco_mode=all
governor=msm-adreno-tz
max_freq=450000000
min_freq=200000000
cap=70
target=75
simple_gpu_activate=1
simple_laziness=3
simple_ramp_threshold=5000
downdifferential=20
upthreshold=50
downthreshold=20
upthreshold_cons=50
read_ahead_kb=1024
scheduler=row
sleep_scheduler=row
>>>>>>> origin/kitkat-ramdisk
auto_oom=on
oom_config_screen_on=medium
oom_config_screen_off=aggressive
dirty_background_ratio=20
dirty_ratio=25
crontab=off
cron_drop_cache=off
ad_block_update=off
cron_db_optimizing=off
cron_clear_app_cache=off
cron_zipalign=off
gpsregion=No_GPS_Zone_changes
init_d=on
logger=off
force_fast_charge=0
fast_charge_level=1800
fake_charge_ac=off
prop_chg_detect=off
usb_keyboard=disable
sweep2sleep=off
cortexbrain_background_process=1
cortexbrain_memory=on
cortexbrain_system=on
cortexbrain_kernel_tweaks=on
cortexbrain_io=on
cifs_module=off
