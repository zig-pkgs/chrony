const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const upstream = b.dependency("upstream", .{});

    const config_h = b.addConfigHeader(.{
        .style = .blank,
    }, .{
        .LINUX = 1,
        .DEBUG = optimize == .debug,
        .FEAT_CMDMON = 1,
        .FEAT_REFCLOCK = 1,
        .HAVE_LONG_TIME_T = 1,
        .NTP_ERA_SPLIT = .@"(1793197998LL - 18250 * 24 * 3600)",
        .HAVE_IN_PKTINFO = 1,
        .FEAT_IPV6 = 1,
        ._GNU_SOURCE = 1,
        .HAVE_IN6_PKTINFO = 1,
        .USE_PTHREAD_ASYNCDNS = 1,
        .HAVE_GETRANDOM = 1,
        .HAVE_RECVMMSG = 1,
        .HAVE_LINUX_TIMESTAMPING = 1,
        .HAVE_LINUX_TIMESTAMPING_RXFILTER_NTP = 1,
        .HAVE_LINUX_TIMESTAMPING_OPT_ID = 1,
        .HAVE_LINUX_TIMESTAMPING_OPT_PKTINFO = 1,
        .HAVE_LINUX_TIMESTAMPING_OPT_TX_SWHW = 1,
        .FEAT_PRIVDROP = 1,
        .FEAT_RTC = 1,
        .FEAT_PHC = 1,
        .HAVE_PTHREAD_SETSCHEDPARAM = 1,
        .HAVE_MLOCKALL = 1,
        .HAVE_SETRLIMIT_MEMLOCK = 1,
        .FORCE_DNSRETRY = 1,
        .FEAT_READLINE = 1,
        .HAVE_NETTLE = 1,
        .FEAT_SECHASH = 1,
        .HAVE_CMAC = 1,
        .HAVE_NETTLE_MEMEQL = 1,
        .HAVE_SIV = 1,
        .HAVE_NETTLE_SIV_GCM = 1,
        .FEAT_NTS = 1,
        .DEFAULT_CONF_FILE = "/etc/chrony.conf",
        .DEFAULT_HWCLOCK_FILE = "",
        .DEFAULT_PID_FILE = "/var/run/chrony/chronyd.pid",
        .DEFAULT_RTC_DEVICE = "/dev/rtc",
        .DEFAULT_USER = "root",
        .DEFAULT_CHRONYC_USER = "root",
        .DEFAULT_COMMAND_SOCKET = "/var/run/chrony/chronyd.sock",
        .MAIL_PROGRAM = "/usr/lib/sendmail",
        .CHRONYC_FEATURES = "+READLINE +SECHASH +IPV6 -DEBUG",
        .CHRONYD_FEATURES = "+CMDMON +REFCLOCK +RTC +PRIVDROP -SCFILTER -SIGND +NTS +SECHASH +IPV6 -DEBUG",
        .CHRONY_VERSION = "4.9",
    });

    const chronyd = b.addExecutable(.{
        .name = "chronyd",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    chronyd.root_module.addConfigHeader(config_h);
    chronyd.root_module.addCSourceFiles(.{
        .root = upstream.path("."),
        .files = &chronyd_src,
    });
    chronyd.root_module.linkSystemLibrary("nettle", .{});
    chronyd.root_module.linkSystemLibrary("gnutls", .{});
    chronyd.root_module.linkSystemLibrary("cap", .{});
    b.installArtifact(chronyd);

    const chronyc = b.addExecutable(.{
        .name = "chronyc",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });
    chronyc.root_module.addConfigHeader(config_h);
    chronyc.root_module.addCSourceFiles(.{
        .root = upstream.path("."),
        .files = &chronyc_src,
    });
    chronyc.root_module.addCSourceFile(.{
        .file = b.path("src/getdate.c"),
    });
    chronyc.root_module.addIncludePath(upstream.path("."));
    chronyc.root_module.linkSystemLibrary("edit", .{});
    chronyc.root_module.linkSystemLibrary("nettle", .{});
    chronyc.root_module.linkSystemLibrary("gnutls", .{});
    b.installArtifact(chronyc);
}

const chronyd_src = [_][]const u8{
    "addrfilt.c",
    "array.c",
    "clientlog.c",
    "cmdmon.c",
    "cmdparse.c",
    "cmac_nettle.c",
    "conf.c",
    "hash_nettle.c",
    "hwclock.c",
    "keys.c",
    "leapdb.c",
    "local.c",
    "logging.c",
    "main.c",
    "manual.c",
    "memory.c",
    "nameserv.c",
    "nameserv_async.c",
    "ntp_auth.c",
    "ntp_core.c",
    "ntp_ext.c",
    "ntp_io.c",
    "ntp_io_linux.c",
    "ntp_sources.c",
    "nts_ke_client.c",
    "nts_ke_server.c",
    "nts_ke_session.c",
    "nts_ntp_auth.c",
    "nts_ntp_client.c",
    "nts_ntp_server.c",
    "pktlength.c",
    "quantiles.c",
    "reference.c",
    "refclock.c",
    "refclock_phc.c",
    "refclock_pps.c",
    "refclock_rtc.c",
    "refclock_sensor.c",
    "refclock_shm.c",
    "refclock_sock.c",
    "regress.c",
    "rtc.c",
    "rtc_linux.c",
    "samplefilt.c",
    "sched.c",
    "siv_nettle.c",
    "smooth.c",
    "socket.c",
    "sources.c",
    "sourcestats.c",
    "stubs.c",
    "sys.c",
    "sys_generic.c",
    "sys_linux.c",
    "sys_null.c",
    "sys_posix.c",
    "sys_timex.c",
    "tempcomp.c",
    "tls_gnutls.c",
    "util.c",
};

const chronyc_src = [_][]const u8{
    "array.c",
    "client.c",
    "cmdparse.c",
    "cmac_nettle.c",
    "hash_nettle.c",
    "memory.c",
    "nameserv.c",
    "pktlength.c",
    "socket.c",
    "util.c",
};
