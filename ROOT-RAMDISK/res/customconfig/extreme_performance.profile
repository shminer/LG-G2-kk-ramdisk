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
<<<<<<< HEAD
<<<<<<< HEAD
min_pwrlevel=4
max_pwrlevel=1
max_gpuclk=450000000
read_ahead_kb=2048
scheduler=fiops
sleep_scheduler=fiops
cortexbrain_cpu=off
=======
=======
suspend_max_freq=4294967295
>>>>>>> origin/kitkat-ramdisk
=======
suspend_max_freq=2803200
>>>>>>> origin/kitkat-ramdisk
msm_thermal=msm_temp
enabled=off
core_limit_temp_degC=80
limit_temp_degC=75
hotplug=msm_hotplug
cpus_boosted=2
eco_mode=all
min_online_cpus=2
gpu_governor=msm-adreno-tz
max_freq=450000000
min_freq=200000000
cap=60
target=70
simple_gpu_activate=1
simple_laziness=3
simple_ramp_threshold=5000
downdifferential=10
upthreshold=40
downthreshold=10
upthreshold_cons=40
lge_cam_mic_gain=10
lge_mic_gain=10
lge_speaker_gain=1
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
<<<<<<< HEAD
ad_block_update=off
cron_db_optimizing=off
cron_clear_app_cache=off
=======
cron_db_optimizing=on
cron_clear_app_cache=on
>>>>>>> origin/kitkat-ramdisk
cron_zipalign=off
tcp_congestion_control=cubic
gpsregion=No_GPS_Zone_changes
<<<<<<< HEAD
init_d=on
logger=off
force_fast_charge=0
=======
init_d=off
logger=2
force_fast_charge=2
>>>>>>> origin/kitkat-ramdisk
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
