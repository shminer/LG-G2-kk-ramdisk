#!/sbin/busybox sh

# Kernel Tuning by Dorimanx.

BB=/sbin/busybox

# protect init from oom
echo "-1000" > /proc/1/oom_score_adj;

PIDOFINIT=$(pgrep -f "/sbin/ext/post-init.sh");
for i in $PIDOFINIT; do
	echo "-600" > /proc/"$i"/oom_score_adj;
done;

OPEN_RW()
{
	ROOTFS_MOUNT=$(mount | grep rootfs | cut -c26-27 | grep -c rw | wc -l)
	SYSTEM_MOUNT=$(mount | grep system | cut -c69-70 | grep -c rw | wc -l)
	if [ "$ROOTFS_MOUNT" -eq "0" ]; then
		$BB mount -o remount,rw /;
	fi;
	if [ "$SYSTEM_MOUNT" -eq "0" ]; then
		$BB mount -o remount,rw /system;
	fi;
}
OPEN_RW;

# run ROM scripts
$BB sh /init.galbi.post_boot.sh;

# fix storage folder owner
$BB chown system.sdcard_rw /storage;

# Boot with fiops I/O Gov
$BB echo "fiops" > /sys/block/mmcblk0/queue/scheduler;


# create init.d folder if missing
if [ ! -d /system/etc/init.d ]; then
	mkdir -p /system/etc/init.d/
	$BB chmod 755 /system/etc/init.d/;
fi;

OPEN_RW;

# some nice thing for dev
if [ ! -e /cpufreq ]; then
	$BB ln -s /sys/devices/system/cpu/cpu0/cpufreq/ /cpufreq;
	$BB ln -s /sys/devices/system/cpu/cpufreq/ /cpugov;
	$BB ln -s /sys/module/msm_thermal/parameters/ /cputemp;
	$BB ln -s /sys/kernel/alucard_hotplug/ /hotplugs/alucard;
	$BB ln -s /sys/kernel/intelli_plug/ /hotplugs/intelli;
	$BB ln -s /sys/module/msm_hotplug/ /hotplugs/msm_hotplug;
	$BB ln -s /sys/devices/system/cpu/cpufreq/all_cpus/ /all_cpus;
fi;

# cleaning
$BB rm -rf /cache/lost+found/* 2> /dev/null;
$BB rm -rf /data/lost+found/* 2> /dev/null;
$BB rm -rf /data/tombstones/* 2> /dev/null;

OPEN_RW;

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

ONDEMAND_TUNING()
{
	echo "80" > /cpugov/ondemand/micro_freq_up_threshold;
	echo "10" > /cpugov/ondemand/down_differential;
	echo "3" > /cpugov/ondemand/down_differential_multi_core;
	echo "1" > /cpugov/ondemand/sampling_down_factor;
	echo "75" > /cpugov/ondemand/up_threshold;
	echo "1574400" > /cpugov/ondemand/sync_freq;
	echo "1574400" > /cpugov/ondemand/optimal_freq;
	echo "1958400" > /cpugov/ondemand/optimal_max_freq;
	echo "20" > /cpugov/ondemand/middle_grid_step;
	echo "30" > /cpugov/ondemand/high_grid_step;
	echo "60" > /cpugov/ondemand/middle_grid_load;
	echo "80" > /cpugov/ondemand/high_grid_load;
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
$BB chmod 666 /sys/devices/system/cpu/cpufreq/all_cpus/*
$BB chmod 666 /sys/devices/system/cpu/cpu1/online
$BB chmod 666 /sys/devices/system/cpu/cpu2/online
$BB chmod 666 /sys/devices/system/cpu/cpu3/online
$BB chmod 666 /sys/module/msm_thermal/parameters/*
$BB chmod 666 /sys/kernel/intelli_plug/*
$BB chmod 666 /sys/class/kgsl/kgsl-3d0/max_gpuclk
$BB chmod 666 /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/governor
$BB chmod 666 /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/*_freq

# make sure our max gpu clock is set via sysfs
echo "578000000" > /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/max_freq;
echo "200000000" > /sys/devices/fdb00000.qcom,kgsl-3d0/devfreq/fdb00000.qcom,kgsl-3d0/min_freq;

# Fix ROM dev wrong sets.
setprop persist.adb.notify 0
setprop pm.sleep_mode 1

if [ ! -d /data/.dori ]; then
	$BB mkdir /data/.dori/;
fi;

# reset profiles auto trigger to be used by kernel ADMIN, in case of need, if new value added in default profiles
# just set numer $RESET_MAGIC + 1 and profiles will be reset one time on next boot with new kernel.
# incase that ADMIN feel that something wrong with global STweaks config and profiles, then ADMIN can add +1 to CLEAN_DORI_DIR
# to clean all files on first boot from /data/.dori/ folder.
RESET_MAGIC=23;
CLEAN_DORI_DIR=1;
if [ ! -e /data/.dori/reset_profiles ]; then
	echo "$RESET_MAGIC" > /data/.dori/reset_profiles;
fi;
if [ ! -e /data/reset_dori_dir ]; then
	echo "$CLEAN_DORI_DIR" > /data/reset_dori_dir;
fi;
if [ -e /data/.dori/.active.profile ]; then
	PROFILE=$(cat /data/.dori/.active.profile);
else
	echo "default" > /data/.dori/.active.profile;
	PROFILE=$(cat /data/.dori/.active.profile);
fi;
if [ "$(cat /data/reset_dori_dir)" -eq "$CLEAN_DORI_DIR" ]; then
	if [ "$(cat /data/.dori/reset_profiles)" != "$RESET_MAGIC" ]; then
		if [ ! -e /data/.dori_old ]; then
			mkdir /data/.dori_old;
		fi;
		cp -a /data/.dori/*.profile /data/.dori_old/;
		$BB rm -f /data/.dori/*.profile;
		if [ -e /data/data/com.af.synapse/databases ]; then
			$BB rm -R /data/data/com.af.synapse/databases;
		fi;
		echo "$RESET_MAGIC" > /data/.dori/reset_profiles;
	else
		echo "no need to reset profiles or delete .dori folder";
	fi;
else
	# Clean /data/.dori/ folder from all files to fix any mess but do it in smart way.
	if [ -e /data/.dori/"$PROFILE".profile ]; then
		cp /data/.dori/"$PROFILE".profile /sdcard/"$PROFILE".profile_backup;
	fi;
	if [ ! -e /data/.dori_old ]; then
		mkdir /data/.dori_old;
	fi;
	cp -a /data/.dori/* /data/.dori_old/;
	$BB rm -f /data/.dori/*
	if [ -e /data/data/com.af.synapse/databases ]; then
		$BB rm -R /data/data/com.af.synapse/databases;
	fi;
	echo "$CLEAN_DORI_DIR" > /data/reset_dori_dir;
	echo "$RESET_MAGIC" > /data/.dori/reset_profiles;
	echo "$PROFILE" > /data/.dori/.active.profile;
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

# Load parameters for Synapse
DEBUG=/data/.dori/;
PVS=$(dmesg | grep "ACPU PVS" | cut -c34-45 | grep -v "REV");
echo "$PVS" > $DEBUG/acpu_pvs;
SPEED=$(dmesg | grep "SPEED BIN" | cut -c34-46);
echo "$SPEED" > $DEBUG/speed_bin;

if [ "$stweaks_boot_control" == "yes" ]; then
        OPEN_RW;
	(
        	# apply STweaks settings
        	$BB sh /res/uci_boot.sh apply;
        	$BB mv /res/uci_boot.sh /res/uci.sh;
		$BB sh /res/synapse/uci;
	)&
fi;

# Apps Install
$BB sh /sbin/ext/install.sh;

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
if [ ! -d /mnt/ntfs ]; then
	$BB mkdir /mnt/ntfs
	$BB mount -t tmpfs -o mode=0777,gid=1000 tmpfs /mnt/ntfs
fi;

# set ondemand tuning.
ONDEMAND_TUNING;

# Turn off CORE CONTROL, to boot on all cores!
$BB chmod 666 /sys/module/msm_thermal/core_control/*
echo "0" > /sys/module/msm_thermal/core_control/core_control;

# Start any init.d scripts that may be present in the rom or added by the user
if [ "$init_d" == "on" ]; then
	$BB chmod 755 /system/etc/init.d/*;
	(
		$BB run-parts /system/etc/init.d/;
	)&
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

if [ "$stweaks_boot_control" == "yes" ]; then
	# Load Custom Modules
	MODULES_LOAD;
	if [ -e /cpugov/ondemand ]; then
		ONDEMAND_TUNING;
	fi;
fi;

echo "0" > /cputemp/freq_limit_debug;

sleep 5;
# Reload usb driver to open MTP and fix fast charge.
CHARGER_STATE=$(cat /sys/class/power_supply/battery/charging_enabled);
if [ "$CHARGER_STATE" -eq "1" ]; then
	echo "0" > /sys/class/android_usb/android0/enable;
	echo "1" > /sys/class/android_usb/android0/enable;
fi;

sleep 30;

if [ "$(cat /sys/power/autosleep)" != "mem" ]; then
	$BB sh /res/uci.sh cpu0_min_freq "$cpu0_min_freq";
	$BB sh /res/uci.sh cpu1_min_freq "$cpu1_min_freq";
	$BB sh /res/uci.sh cpu2_min_freq "$cpu2_min_freq";
	$BB sh /res/uci.sh cpu3_min_freq "$cpu3_min_freq";

	# Reload SuperSU daemonsu to fix SuperUser bugs.
	if [ -e /system/xbin/daemonsu ]; then
        	pkill -f "daemonsu";
        	/system/xbin/daemonsu --auto-daemon &
	fi;
fi;

# script finish here, so let me know when
TIME_NOW=$(date)
echo "$TIME_NOW" > /data/boot_log_dm
