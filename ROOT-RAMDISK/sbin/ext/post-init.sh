#!/sbin/busybox sh

# Kernel Tuning by Dorimanx.

BB=/sbin/busybox

# protect init from oom
echo "-1000" > /proc/1/oom_score_adj;

PIDOFINIT=$(pgrep -f "/sbin/ext/post-init.sh");
for i in $PIDOFINIT; do
	echo "-600" > /proc/"$i"/oom_score_adj;
done;

# set high priority to temp controller
$BB renice -n -20 -p $(pgrep -f "/system/bin/thermal-engine");

OPEN_RW()
{
        $BB mount -o remount,rw /;
        $BB mount -o remount,rw /system;
}
OPEN_RW;

# fix storage folder owner
$BB chown system.sdcard_rw /storage;

# Boot with fiops I/O Gov
$BB echo "fiops" > /sys/block/mmcblk0/queue/scheduler;


# create init.d folder if missing
if [ ! -d /system/etc/init.d ]; then
	mkdir -p /system/etc/init.d/
	$BB chmod 755 /system/etc/init.d/;
fi;

(
	if [ ! -d /data/init.d_bkp ]; then
		$BB mkdir /data/init.d_bkp;
	fi;
	$BB mv /system/etc/init.d/* /data/init.d_bkp/;
        # run ROM scripts
        if [ -e /system/etc/init.galbi.post_boot.sh ]; then
                $BB sh /system/etc/init.galbi.post_boot.sh
        else
                $BB echo "No ROM Boot script detected"
        fi;
	$BB mv /data/init.d_bkp/* /system/etc/init.d/
)&

sleep 5;
OPEN_RW;

# some nice thing for dev
if [ ! -e /cpufreq ]; then
	$BB ln -s /sys/devices/system/cpu/cpu0/cpufreq /cpufreq;
	$BB ln -s /sys/devices/system/cpu/cpufreq/ /cpugov;
	$BB ln -s /sys/module/msm_thermal/parameters/ /cputemp;
	$BB ln -s /sys/kernel/alucard_hotplug/ /alucard_plug;
	$BB ln -s /sys/kernel/intelli_plug/ /intelli_plug;
fi;

# cleaning
$BB rm -rf /cache/lost+found/* 2> /dev/null;
$BB rm -rf /data/lost+found/* 2> /dev/null;
$BB rm -rf /data/tombstones/* 2> /dev/null;

CRITICAL_PERM_FIX()
{
	# critical Permissions fix
	$BB chown -R system:system /data/anr;
	$BB chown -R root:root /tmp;
	$BB chown -R root:root /res;
	$BB chown -R root:root /sbin;
	$BB chown -R root:root /lib;
	$BB chmod -R 777 /tmp/;
	$BB chmod -R 775 /res/;
	$BB chmod -R 06755 /sbin/ext/;
	$BB chmod -R 0777 /data/anr/;
	$BB chmod -R 0400 /data/tombstones;
	$BB chmod 06755 /sbin/busybox
}
CRITICAL_PERM_FIX;

SOUND_FIX()
{
		# fix mic and speaker low sound on boot.
		sleep 60;
		echo "24" > /sys/kernel/sound_control_3/lge_cam_mic_gain;
		echo "30" > /sys/kernel/sound_control_3/lge_mic_gain;
		echo "2 2" > /sys/kernel/sound_control_3/lge_speaker_gain;
		echo "sound fixed" > /data/.dori/sound_fix_on_boot;
}

ONDEMAND_TUNING()
{
	echo "10" > /cpugov/ondemand/down_differential;
	echo "3" > /cpugov/ondemand/down_differential_multi_core;
	echo "80" > /cpugov/ondemand/micro_freq_up_threshold;
	echo "1" > /cpugov/ondemand/sampling_down_factor;
	echo "50000" > /cpugov/ondemand/sampling_rate;
	echo "75" > /cpugov/ondemand/up_threshold;
	echo "75" > /cpugov/ondemand/up_threshold_any_cpu_load;
	echo "75" > /cpugov/ondemand/up_threshold_multi_core;
	echo "1497600" > /cpugov/ondemand/sync_freq;
	echo "1497600" > /cpugov/ondemand/optimal_freq;
	echo "2265600" > /cpugov/ondemand/optimal_max_freq;
	echo "10" > /cpugov/ondemand/middle_grid_step;
	echo "15" > /cpugov/ondemand/high_grid_step;
	echo "30" > /cpugov/ondemand/middle_grid_load;
	echo "40" > /cpugov/ondemand/high_grid_load;
	echo "300000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;
}

# oom and mem perm fix
$BB chmod 666 /sys/module/lowmemorykiller/parameters/cost;
$BB chmod 666 /sys/module/lowmemorykiller/parameters/adj;
$BB chmod 666 /sys/module/lowmemorykiller/parameters/minfree

# make sure we own the device nodes
$BB chown system /sys/devices/system/cpu/cpufreq/ondemand/*
$BB chown system /sys/devices/system/cpu/cpu0/cpufreq/*
$BB chown system /sys/devices/system/cpu/cpu1/online
$BB chown system /sys/devices/system/cpu/cpu2/online
$BB chown system /sys/devices/system/cpu/cpu3/online
$BB chmod 666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
$BB chmod 666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq
$BB chmod 666 /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq
$BB chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_cur_freq
$BB chmod 444 /sys/devices/system/cpu/cpu0/cpufreq/stats/*
$BB chmod 666 /sys/devices/system/cpu/cpu1/online
$BB chmod 666 /sys/devices/system/cpu/cpu2/online
$BB chmod 666 /sys/devices/system/cpu/cpu3/online
$BB chmod 666 /sys/module/msm_thermal/parameters/*
$BB chmod 666 /sys/module/msm_thermal/core_control/enabled
$BB chmod 666 /sys/kernel/intelli_plug/*
$BB chmod 666 /sys/class/kgsl/kgsl-3d0/max_gpuclk
$BB chmod 666 /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/governor

# make sure our max gpu clock is set via sysfs
echo "578000000" > /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/max_freq

# set min max boot freq to default.
echo "2803200" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq;
echo "300000" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq;

# Fix ROM dev wrong sets.
setprop persist.adb.notify 0
setprop persist.service.adb.enable 1
setprop dalvik.vm.execution-mode int:jit
setprop pm.sleep_mode 1

if [ ! -d /data/.dori ]; then
	$BB mkdir -p /data/.dori;
fi;

# reset config-backup-restore
if [ -f /data/.dori/restore_running ]; then
	$BB rm -f /data/.dori/restore_running;
fi;

# reset profiles auto trigger to be used by kernel ADMIN, in case of need, if new value added in default profiles
# just set numer $RESET_MAGIC + 1 and profiles will be reset one time on next boot with new kernel.
RESET_MAGIC=10;
if [ ! -e /data/.dori/reset_profiles ]; then
	echo "0" > /data/.dori/reset_profiles;
fi;
if [ "$(cat /data/.dori/reset_profiles)" -eq "$RESET_MAGIC" ]; then
	echo "no need to reset profiles";
else
	$BB rm -f /data/.dori/*.profile;
	echo "$RESET_MAGIC" > /data/.dori/reset_profiles;
fi;

[ ! -f /data/.dori/default.profile ] && cp -a /res/customconfig/default.profile /data/.dori/default.profile;
[ ! -f /data/.dori/battery.profile ] && cp -a /res/customconfig/battery.profile /data/.dori/battery.profile;
[ ! -f /data/.dori/performance.profile ] && cp -a /res/customconfig/performance.profile /data/.dori/performance.profile;
[ ! -f /data/.dori/extreme_performance.profile ] && cp -a /res/customconfig/extreme_performance.profile /data/.dori/extreme_performance.profile;
[ ! -f /data/.dori/extreme_battery.profile ] && cp -a /res/customconfig/extreme_battery.profile /data/.dori/extreme_battery.profile;

$BB chmod -R 0777 /data/.dori/;

. /res/customconfig/customconfig-helper;
read_defaults;
read_config;

(
	# Apps Install
	$BB sh /sbin/ext/install.sh;
)&

######################################
# Loading Modules
######################################
MODULES_LOAD()
{
	# order of modules load is important

	if [ "$cifs_module" == "on" ]; then
		if [ -e /system/lib/modules/cifs.ko ]; then
			$BB insmod /system/lib/modules/cifs.ko;
		else
			$BB insmod /lib/modules/cifs.ko;
		fi;
	else
		echo "no user modules loaded";
	fi;
}

# enable kmem interface for everyone by GM
echo "0" > /proc/sys/kernel/kptr_restrict;

# disable debugging on some modules
if [ "$logger" -ge "1" ]; then
	echo "N" > /sys/module/kernel/parameters/initcall_debug;
#	echo "0" > /sys/module/alarm/parameters/debug_mask;
#	echo "0" > /sys/module/alarm_dev/parameters/debug_mask;
#	echo "0" > /sys/module/binder/parameters/debug_mask;
	echo "0" > /sys/module/xt_qtaguid/parameters/debug_mask;
#	echo "0" > /sys/kernel/debug/clk/debug_suspend;
#	echo "0" > /sys/kernel/debug/msm_vidc/debug_level;
#	echo "0" > /sys/module/ipc_router/parameters/debug_mask;
#	echo "0" > /sys/module/msm_serial_hs/parameters/debug_mask;
#	echo "0" > /sys/module/msm_show_resume_irq/parameters/debug_mask;
#	echo "0" > /sys/module/mpm_of/parameters/debug_mask;
#	echo "0" > /sys/module/msm_pm/parameters/debug_mask;
#	echo "0" > /sys/module/smp2p/parameters/debug_mask;
fi;

OPEN_RW;

# for ntfs automounting
$BB mkdir /mnt/ntfs
$BB mount -t tmpfs -o mode=0777,gid=1000 tmpfs /mnt/ntfs

(
	# set ondemand as default gov
	echo "ondemand" > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor;
	ONDEMAND_TUNING;

	if [ "$stweaks_boot_control" == "yes" ]; then
		# stop uci.sh from running all the PUSH Buttons in stweaks on boot
		OPEN_RW;
		$BB chown -R root:system /res/customconfig/actions/;
		$BB chmod -R 06755 /res/customconfig/actions/;
		$BB mv /res/customconfig/actions/push-actions/* /res/no-push-on-boot/;
		$BB chmod 06755 /res/no-push-on-boot/*;

		# apply STweaks settings
		$BB pkill -f "com.gokhanmoral.stweaks.app";
		$BB nohup $BB sh /res/uci.sh restore;

		OPEN_RW;
		# restore all the PUSH Button Actions back to there location
		$BB mv /res/no-push-on-boot/* /res/customconfig/actions/push-actions/;
		$BB pkill -f "com.gokhanmoral.stweaks.app";

		# correct oom tuning, if changed by apps/rom
		$BB sh /res/uci.sh oom_config_screen_on "$oom_config_screen_on";
		$BB sh /res/uci.sh oom_config_screen_off "$oom_config_screen_off";

		# Load Custom Modules
		MODULES_LOAD;
		if [ -e /cpugov/ondemand ]; then
			ONDEMAND_TUNING;
		fi;
	fi;

	# Start any init.d scripts that may be present in the rom or added by the user
	if [ "$init_d" == "on" ]; then
		$BB chmod 755 /system/etc/init.d/*;
		$BB run-parts /system/etc/init.d/;
	else
		if [ -e /system/etc/init.d/99SuperSUDaemon ]; then
			$BB chmod 755 /system/etc/init.d/*;
			$BB sh /system/etc/init.d/99SuperSUDaemon;
		else
			echo "no root script in init.d";
		fi;
	fi;

	# Fix critical perms again after init.d mess
	CRITICAL_PERM_FIX;

	# fix sound gain
	SOUND_FIX;

	# script finish here, so let me know when
	TIME_NOW=$(date)
	echo "$TIME_NOW" > /data/boot_log_dm
)&

