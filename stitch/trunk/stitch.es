;; -*- scheme -*-
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemconfig.c" :point 8802 :coding-system undecided-unix :line 297 :surround ("
" "" "	strcpy (totem_config->rrp_mode, \"none\");
") :which-func ("totem_config_read"))) :annotation-list ((annotation :type text :data "active,passive,noneからデフォルトはnone。")) :date "Mon Nov 16 02:16:02 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemudp.c" :point 49674 :coding-system undecided-unix :line 1875 :surround ("
" "" "int totemudp_mcast_noflush_send (
	void *udp_context,") :which-func ("totemudp_mcast_noflush_send"))) :annotation-list ((annotation :type text :data "threadsがonの場合キューに入るが、そうでなければ、totemudp_mcast_flush_sendと同じ。")) :date "Mon Nov 16 02:18:29 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemrrp.c" :point 14495 :coding-system undecided-unix :line 580 :surround ("{
" "" "	totemnet_token_target_set (instance->net_handles[0], token_target);
}") :which-func ("none_token_target_set"))) :annotation-list ((annotation :type text :data "interfaceを引数に渡しているが、使っていない。single ring?")) :date "Mon Nov 16 02:48:57 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemrrp.c" :point 23893 :coding-system undecided-unix :line 922 :surround ("
" "" "static void passive_token_target_set (
	struct totemrrp_instance *instance,") :which-func ("passive_token_target_set"))) :annotation-list ((annotation :type text :data "activeでもpassiveでも同じ。各インターフェイス毎に処理している。")) :date "Mon Nov 16 02:50:11 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 27162 :coding-system undecided-unix :line 1080 :surround ("                if (quorum_device->state == NODESTATE_DEAD) {
" "" "                        quorum_device->state = NODESTATE_MEMBER;
                        recalculate_quorum(0, 0);") :which-func ("do_cmd_poll_quorum_device"))) :annotation-list ((annotation :type text :data "quorum deviceを1ノードとみなしてメンバーにている。")) :date "Wed Nov 18 02:33:47 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 24651 :coding-system undecided-unix :line 1016 :surround ("			if (!errors)
" "" "				cman_poll_quorum_device(ctx->qc_ch, 1);
") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "ここでquorumデバイスがあたかもノードとして与えられたvoteを維持。")) :date "Wed Nov 18 02:38:25 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 25276 :coding-system undecided-unix :line 1036 :surround ("				if (!errors)
" "" "					cman_poll_quorum_device(ctx->qc_ch, 1);
			}") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "???")) :date "Wed Nov 18 02:39:26 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 21604 :coding-system undecided-unix :line 903 :surround ("				} else {
" "" "					cman_poll_quorum_device(ctx->qc_ch, 0);
				}") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "quorumデバイスのvoteを破棄")) :date "Wed Nov 18 02:40:03 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 7491 :coding-system undecided-unix :line 288 :surround ("
" "" "	list_iterate(nodelist, &cluster_members_list) {
		node = list_item(nodelist, struct cluster_node);") :which-func ("calculate_quorum"))) :annotation-list ((annotation :type text :data "参加しているノード全員のvotesの和を計算(total_votes)
参加しているノード全員のexpected votesのうち最大のものを求める(highest_expected)")) :date "Wed Nov 18 02:43:09 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 7760 :coding-system undecided-unix :line 298 :surround ("	}
" "" "	if (quorum_device && quorum_device->state == NODESTATE_MEMBER)
		total_votes += quorum_device->votes;") :which-func ("calculate_quorum"))) :annotation-list ((annotation :type text :data "quorum_deviceが有効であれば、それに与えられているvoteを加算")) :date "Wed Nov 18 02:44:21 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/qdisk/main.c" :point 25276 :coding-system undecided-unix :line 1036 :surround ("				if (!errors)
" "" "					cman_poll_quorum_device(ctx->qc_ch, 1);
			}") :which-func ("quorum_loop"))) :annotation-list ((annotation :type text :data "これだと masterでもmasterでなくともvoteをかせげる。")) :date "Wed Nov 18 11:18:29 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/commands.c" :point 32464 :coding-system undecided-unix :line 1285 :surround ("	case CMAN_CMD_ISQUORATE:
" "" "		return cluster_is_quorate;
") :which-func ("process_command"))) :annotation-list ((annotation :type text :data "この変数を見ればquorateかどうかわかる。")) :date "Wed Nov 18 11:20:06 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/lib/libcman.h" :point 2306 :coding-system undecided-unix :line 62 :surround ("typedef enum {CMAN_REASON_PORTCLOSED,
" "" "	      CMAN_REASON_STATECHANGE,
              CMAN_REASON_PORTOPENED,")) (target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/cman/daemon/cnxman-socket.h" :point 4173 :coding-system undecided-unix :line 104 :surround ("#define EVENT_REASON_PORTCLOSED   0
" "" "#define EVENT_REASON_STATECHANGE  1
#define EVENT_REASON_PORTOPENED   2"))) :annotation-list ((annotation :type text :data "CMAN_REASON_STATECHANGE == EVENT_REASON_STATECHANGE")) :date "Wed Nov 18 12:03:31 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/group/daemon/cman.c" :point 3171 :coding-system undecided-unix :line 129 :surround ("		break;
" "" "	case CMAN_REASON_STATECHANGE:
		statechange();") :which-func ("cman_callback"))) :annotation-list ((annotation :type text :data "cman daemonのrecalculate_quorumから来る。")) :date "Wed Nov 18 12:05:46 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/fence/fenced/agent.c" :point 6102 :coding-system undecided-unix :line 297 :surround ("
" "" "	/* Mark it as fenced */
	if (!cman_get_node(ch, 0, &node))") :which-func ("update_cman"))) :annotation-list ((annotation :type text :data "fencingが完了したことを伝えるために、cmanを呼ぶ。")) :date "Thu Nov 19 11:46:29 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/r/readline/6.0-3.fc12/pre-build/readline-6.0/text.c" :point 9679 :coding-system undecided-unix :line 435 :surround ("/* Move forward a word.  We do what Emacs does.  Handles multibyte chars. */
" "" "int
rl_forward_word (count, key)") :which-func ("rl_end_of_line"))) :annotation-list ((annotation :type text :data "forward char")) :date "Wed Jan 20 02:50:01 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (readline-subword))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/o/openssh/4.3p2-36.el5_4.4/pre-build/openssh-4.3p2/auth.c" :point 7400 :coding-system undecided-unix :line 251 :surround ("
" "" "	authlog(\"%s %s for %s%.100s from %.200s port %d%s\",
	    authmsg,") :which-func ("auth_log"))) :annotation-list ((annotation :type text :data "%.100sで長すぎる名前の入力を遮断している。")) :date "Tue Mar 16 02:17:03 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (just-reading security))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/j/java-1.6.0-openjdk/1.6.0.0-35.b17.fc13/vanilla/hotspot/src/share/vm/runtime/thread.cpp" :point 135818 :coding-system undecided-unix :line 3734 :surround ("// Threads::print_on() is called at safepoint by VM_PrintThreads operation.
" "" "void Threads::print_on(outputStream* st, bool print_stacks, bool internal_format, bool print_concurrent_locks) {
  char buf[32];") :which-func ("Threads::print_on"))) :annotation-list ((annotation :type text :data "javaのスタックトレース")) :date "Wed Apr  7 05:33:50 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (xbacktrace))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/jet/var/emacs/trunk/src/.gdbinit" :point 27159 :coding-system undecided-unix :line 1185 :surround ("
" "" "define xbacktrace
  set $bt = backtrace_list") :which-func ("xbacktrace"))) :annotation-list ((annotation :type text :data "emacsのバックトレース")) :date "Wed Apr  7 05:34:10 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (xbacktrace))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/2.0.98-1.el5_3.8/pre-build/cman-2.0.98/fence/fenced/group.c" :point 3576 :coding-system undecided-unix :line 162 :surround ("
" "" "	gh = group_init(NULL, \"fence\", 0, &callbacks, GROUPD_TIMEOUT);
	if (!gh) {") :which-func ("setup_groupd"))) :annotation-list ((annotation :type text :data "group_initの引数のレベル(ここでは0)で通知の優先度が決まるのか？")) :date "Sun Apr 18 22:03:20 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-cluster))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/^lcopy-trunk/pre-build/linux-2.6/net/unix/af_unix.c" :point 26510 :coding-system undecided-unix :line 1036 :surround ("
" "" "	if (test_bit(SOCK_PASSCRED, &sock->flags) && !u->addr &&
	    (err = unix_autobind(sock)) != 0)") :which-func ("unix_stream_connect"))) :annotation-list ((annotation :type text :data "!u->addr: バインドされていなかったら。")) :date "Sun May 16 04:03:12 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-lsof-cant-identify-protocol))
(stitch-annotation :version 0 :target-list ((target :type file :file "/net/sop/srv/sources/attic/cradles/lcopy.sys/mirror/k/kernel/trunk/pre-build/linux-2.6/net/ipv4/af_inet.c" :point 19440 :coding-system undecided-unix :line 778 :surround ("		if (sk->sk_prot->shutdown)
" "" "			sk->sk_prot->shutdown(sk, how);
		break;") :which-func ("inet_shutdown"))) :annotation-list ((annotation :type text :data "ここで tcp_shutdown を呼ぶ。")) :date "Tue May 18 01:14:13 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-lsof-cant-identify-protocol))
(stitch-annotation :version 0 :target-list ((target :type file :file "/net/sop/srv/sources/attic/cradles/lcopy.sys/mirror/k/kernel/trunk/pre-build/linux-2.6/net/ipv4/tcp.c" :point 49642 :coding-system undecided-unix :line 1865 :surround ("		/* Clear out any half completed packets.  FIN if needed. */
" "" "		if (tcp_close_state(sk))
			tcp_send_fin(sk);") :which-func ("tcp_shutdown"))) :annotation-list ((annotation :type text :data "sk->sk_shutdownにhowが設定されている。")) :date "Tue May 18 01:18:43 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-lsof-cant-identify-protocol))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.9-89.EL/pre-build/kernel-2.6.9/linux-2.6.9/configs/kernel-2.6.9-x86_64.config" :point 117 :coding-system undecided-unix :line 6 :surround ("#
" "" "CONFIG_X86_64=y
CONFIG_64BIT=y") :which-func ("CONFIG_X86_64"))) :annotation-list ((annotation :type text :data "THIS IS AN EXAMPLE ANNOTATION.")) :date "Thu Aug 12 09:53:13 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (example))

(stitch-annotation :version 0 :target-list ((target :type directory :directory "/srv/sources/" :item ".")) :annotation-list ((annotation :type text :data "THIS IS SOURCES.")) :date "Sun Dec 12 09:10:18 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (*DRAFT*))

(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/dists/rhel5su4/packages/k/kernel/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/fs/nfs/read.c" :point 18494 :coding-system undecided-unix :line 724 :surround ("	 */
" "" "	ret = nfs_readpages_from_fscache(desc.ctx, inode, mapping,
					 pages, &nr_pages);") :which-func ("nfs_readpages"))) :annotation-list ((annotation :type text :data "nfs_file_read <ここでgetattrしてサーバ側で変更があれば、キャッシュをinvalidとする処理がある？>
-> generic_file_aio_read
--> <page cache layer> ... nfs_readpages
---> nfs_readpages_from_fscache|read_cache_pages")) :date "Thu Dec 30 01:30:25 2010" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (*DRAFT* nfs-atime))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/dists/rhel5su4/packages/k/kernel/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/fs/nfs/inode.c" :point 19252 :coding-system undecided-unix :line 725 :surround ("			nfs_sync_mapping(mapping);
" "" "		invalidate_inode_pages3(mapping);
") :which-func ("nfs_revalidate_mapping"))) :annotation-list ((annotation :type text :data "ここでページキャッシュから追い出している。")) :date "Mon Jan  3 17:14:30 2011" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (nfs-atime))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/dists/rhel5su4/packages/k/kernel/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/mm/filemap.c" :point 31149 :coding-system undecided-unix :line 1100 :surround ("	if (filp)
" "" "		file_accessed(filp);
}") :which-func ("do_generic_mapping_read"))) :annotation-list ((annotation :type text :data "ここでタイムスタンプ(atime)を更新")) :date "Mon Jan  3 18:16:11 2011" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (nfs-atime))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/jet/srpmix/sources/c/corosync/1.3.1-1.fc14/pre-build/corosync-1.3.1/exec/totemconfig.c" :point 2705 :coding-system undecided-unix :line 74 :surround ("#define JOIN_TIMEOUT				50
" "" "#define MERGE_TIMEOUT				200
#define DOWNCHECK_TIMEOUT			1000"))) :annotation-list ((annotation :type text :data "0.2秒tokenが更新されていなくて、GATHERでもCOMMITでもRECOVERYでもなければ、
merge送信(gatherのことか)")) :date "Fri May 27 03:27:55 2011" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/jet/srpmix/sources/c/cluster/3.1.1-1.fc14/pre-build/cluster-3.1.1/cman/daemon/ais.c" :point 10821 :coding-system undecided-unix :line 343 :surround ("		log_printf(LOGSYS_LEVEL_DEBUG, \"ais: last memb_count = %d, current = %\"PRIuFAST32\"\\n\", last_memb_count, member_list_entries);
" "" "		send_transition_msg(last_memb_count, first_trans);
		last_memb_count = member_list_entries;") :which-func ("cman_confchg_fn"))) :annotation-list ((annotation :type text :data "この先、quorumの再計算でクラスターメッセージを送信する。
そのメッセージの先でfencingか？")) :date "Thu Jun  9 03:45:39 2011" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-cluster))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/ipv4/tcp_input.c" :point 46386 :coding-system undecided-unix :line 1430 :surround ("
" "" "	tcp_unlink_write_queue(skb, sk);
	sk_wmem_free_skb(sk, skb);") :which-func "tcp_shifted_skb")) :annotation-list ((annotation :type text :data "ackを受けてここにきてwmemを広げる。")) :date "Fri Mar  2 01:27:08 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-qdisc))

(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/^alias-rhel5su7/pre-build/multipath-tools-0.4.7.rhel5.30/libmultipath/configure.c" :point 1626 :coding-system undecided-unix :line 81 :surround ("	}
" "" "	if (mpp->pgpolicyfn && mpp->pgpolicyfn(mpp))
		return 1;") :which-func "setup_map")) :annotation-list ((annotation :type text :data "ここでpgpolicyfnを呼び出している。")) :date "Fri Mar 16 08:51:34 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/g/graphviz/2.26.0-7.el6/pre-build/graphviz-2.26.0/lib/common/shapes.c" :point 59984 :coding-system undecided-unix :line 2340 :surround ("
" "" "static void gen_fields(GVJ_t * job, node_t * n, field_t * f)
{") :which-func "gen_fields")) :annotation-list ((annotation :type text :data "ここでフィールドを書き出している。")) :date "Wed Mar 21 11:12:53 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/g/graphviz/2.26.0-7.el6/pre-build/graphviz-2.26.0/lib/common/shapes.c" :point 60586 :coding-system undecided-unix :line 2365 :surround ("	    AF[1] = add_pointf(AF[1], coord);
" "" "	    gvrender_polyline(job, AF, 2);
	}") :which-func "gen_fields")) :annotation-list ((annotation :type text :data "ここでレンダーしているのでまわりにアンカーを張れれば良い。")) :date "Wed Mar 21 11:13:29 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(define-keyword hacking-graphviz-record-field-tooltips :version 0 :keywords hacking-graphviz-record-field-tooltips :subject "recordにフィールドにtooltips/urlを定義できるようにする。

	record:field[...];

で定義できれば良い。" :date "Wed Mar 21 11:16:05 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com")
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/g/graphviz/2.26.0-7.el6/pre-build/graphviz-2.26.0/lib/common/shapes.c" :point 6263 :coding-system undecided-unix :line 167 :surround ("
" "" "static shape_desc Shapes[] = {	/* first entry is default for no such shape */
    {\"box\", &poly_fns, &p_box},"))) :annotation-list ((annotation :type text :data "形(shape)毎のハンドラ一覧。")) :date "Wed Mar 21 11:19:30 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/yamato/var/graphviz/lib/agraph/agraph.h" :point 9451 :coding-system undecided-unix :line 267 :surround ("    extern Agnode_t *agfstnode(Agraph_t * g);
" "" "    extern Agnode_t *agnxtnode(Agnode_t * n);
") :which-func "NIL")) :annotation-list ((annotation :type text :data "nextノード")) :date "Fri Mar 23 10:36:43 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/yamato/var/graphviz/lib/agraph/agraph.h" :point 9405 :coding-system undecided-unix :line 266 :surround ("    extern Agnode_t *agsubnode(Agraph_t * g, Agnode_t * n, int createflag);
" "" "    extern Agnode_t *agfstnode(Agraph_t * g);
    extern Agnode_t *agnxtnode(Agnode_t * n);") :which-func "NIL")) :annotation-list ((annotation :type text :data "firstノード")) :date "Fri Mar 23 10:37:49 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/yamato/var/graphviz/lib/agraph/agraph.h" :point 10736 :coding-system undecided-unix :line 298 :surround ("    extern int aghtmlstr(char *);
" "" "    extern char *agstrbind(Agraph_t * g, char *);
    extern int agstrfree(Agraph_t *, char *);") :which-func "NIL")) :annotation-list ((annotation :type text :data "== intern")) :date "Fri Mar 23 10:39:02 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/home/yamato/var/graphviz/lib/agraph/agraph.h" :point 11113 :coding-system undecided-unix :line 307 :surround ("	Dict_t *dict;		/* shared dict to interpret attr field */
" "" "	char **str;		/* the attribute string values */
    };") :which-func "NIL")) :annotation-list ((annotation :type text :data "indexでアクセスする。")) :date "Fri Mar 23 10:40:38 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/g/graphviz/2.26.0-7.el6/pre-build/graphviz-2.26.0/lib/cgraph/id.c" :point 2138 :coding-system undecided-unix :line 91 :surround ("
" "" "int agmapnametoid(Agraph_t * g, int objtype, char *str,
		  unsigned long *result, int createflag)") :which-func "agmapnametoid")) :annotation-list ((annotation :type text :data "ここでidを作る。")) :date "Fri Mar 23 13:39:01 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (hacking-graphviz-record-field-tooltips))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_monitor.c" :point 16721 :coding-system undecided-unix :line 635 :surround ("
" "" "        /* Make sure anyone waiting wakes up now */
        virCondSignal(&mon->notify);") :which-func "qemuMonitorIO")) :annotation-list ((annotation :type text :data "ここでqemuとのソケット切れを処理している。")) :date "Mon Mar 26 12:26:01 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-libvirt))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_process.c" :point 106565 :coding-system undecided-unix :line 3424 :surround ("        /* we can't stop the operation even if the script raised an error */
" "" "        virHookCall(VIR_HOOK_DRIVER_QEMU, vm->def->name,
                    VIR_HOOK_QEMU_OP_RELEASE, VIR_HOOK_SUBOP_END, NULL, xml);") :which-func "qemuProcessStop")) :annotation-list ((annotation :type text :data "コマンドを呼べる。")) :date "Mon Mar 26 12:32:36 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-libvirt))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_monitor.c" :point 15231 :coding-system undecided-unix :line 592 :surround ("                            _(\"Invalid file descriptor while waiting for monitor\"));
" "" "            eof = 1;
            events &= ~VIR_EVENT_HANDLE_ERROR;") :which-func "qemuMonitorIO")) :annotation-list ((annotation :type text :data "ここれはtrueとすべき。")) :date "Mon Mar 26 12:35:39 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-libvirt patch-queue))

(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_monitor.c" :point 17333 :coding-system undecided-unix :line 651 :surround ("        VIR_DEBUG(\"Triggering error callback\");
" "" "        (errorNotify)(mon, vm);
    } else {") :which-func "qemuMonitorIO")) :annotation-list ((annotation :type text :data "???")) :date "Mon Mar 26 12:37:03 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-libvirt))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_monitor.c" :point 16931 :coding-system undecided-unix :line 640 :surround ("        VIR_DEBUG(\"Triggering EOF callback\");
" "" "        (eofNotify)(mon, vm);
    } else if (error) {") :which-func "qemuMonitorIO")) :annotation-list ((annotation :type text :data "=> qemuProcessHandleMonitorEOF")) :date "Mon Mar 26 12:37:32 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-libvirt))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/q/qemu-kvm/0.12.1.2-2.209.el6/pre-build/qemu-kvm-0.12.1.2/hw/wdt_i6300esb.c" :point 6042 :coding-system undecided-unix :line 181 :surround ("        /* What to do at the end of stage 1? */
" "" "        switch (d->int_type) {
        case INT_TYPE_IRQ:") :which-func "i6300esb_timer_expired")) :annotation-list ((annotation :type text :data "ウォッチドッグにひっかかった場合ここでstderrに記録する。
stderrは誰が回収してくれるのか？")) :date "Fri Mar 30 18:04:33 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/q/qemu-kvm/0.12.1.2-2.209.el6/pre-build/qemu-kvm-0.12.1.2/qemu-options.hx" :point 69457 :coding-system undecided-unix :line 1948 :surround ("
" "" "DEF(\"watchdog-action\", HAS_ARG, QEMU_OPTION_watchdog_action, \\
    \"-watchdog-action reset|shutdown|poweroff|pause|debug|none\\n\" \\"))) :annotation-list ((annotation :type text :data "qemuの起動オプションに-watchdog ...をつけるとwatchdogタイムアウト時の挙動を
指定できる。")) :date "Tue Apr  3 14:16:17 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/q/qemu-kvm/0.12.1.2-2.209.el6/pre-build/qemu-kvm-0.12.1.2/hw/wdt_i6300esb.c" :point 6602 :coding-system undecided-unix :line 196 :surround ("            d->previous_reboot_flag = 1;
" "" "            watchdog_perform_action(); /* This reboots, exits, etc */
            i6300esb_reset(&d->dev.qdev);") :which-func "i6300esb_timer_expired")) :annotation-list ((annotation :type text :data "ここからスタート")) :date "Tue Apr  3 14:52:21 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 11214 :coding-system undecided-unix :line 293 :surround ("	 */
" "" "	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
	    (unsigned)sk->sk_rcvbuf) {") :which-func "sock_queue_rcv_skb")) :annotation-list ((annotation :type text :data "sk_rmem_allocはskb_set_owner_rで更新する。
すなわち受信用にskを受け入れると増加する。")) :date "Tue Apr  3 23:05:42 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 11214 :coding-system undecided-unix :line 293 :surround ("	 */
" "" "	if (atomic_read(&sk->sk_rmem_alloc) + skb->truesize >=
	    (unsigned)sk->sk_rcvbuf) {") :which-func "sock_queue_rcv_skb")) :annotation-list ((annotation :type text :data "sk->sk_rcvbufはSO_RCVBUFによって設定できるソケット毎のリード用
メモリの上限。")) :date "Tue Apr  3 23:10:38 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 41519 :coding-system undecided-unix :line 1624 :surround ("	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
" "" "	allocated = atomic_add_return(amt, prot->memory_allocated);
") :which-func "__sk_mem_schedule")) :annotation-list ((annotation :type text :data "プロトコル単位のメモリ使用量")) :date "Tue Apr  3 23:13:03 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 41767 :coding-system undecided-unix :line 1634 :surround ("	/* Under pressure. */
" "" "	if (allocated > prot->sysctl_mem[1])
		if (prot->enter_memory_pressure)") :which-func "__sk_mem_schedule")) :annotation-list ((annotation :type text :data "/proc/sys/net/ipv4/udp_memの2番目")) :date "Tue Apr  3 23:14:24 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 41901 :coding-system undecided-unix :line 1639 :surround ("	/* Over hard limit. */
" "" "	if (allocated > prot->sysctl_mem[2])
		goto suppress_allocation;") :which-func "__sk_mem_schedule")) :annotation-list ((annotation :type text :data "/proc/sys/net/ipv4/udp_memの3番目")) :date "Tue Apr  3 23:14:41 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/sock.c" :point 42048 :coding-system undecided-unix :line 1644 :surround ("	if (kind == SK_MEM_RECV) {
" "" "		if (atomic_read(&sk->sk_rmem_alloc) < prot->sysctl_rmem[0])
			return 1;") :which-func "__sk_mem_schedule")) :annotation-list ((annotation :type text :data "ソケット単位の受信のメモリ使用量とプロトコル毎に与える「ソケット単位の受信のメモリ使用」下限の比較")) :date "Tue Apr  3 23:24:16 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_process.c" :point 89499 :coding-system undecided-unix :line 2908 :surround ("    VIR_DEBUG(\"Creating domain log file\");
" "" "    if ((logfile = qemuDomainCreateLog(driver, vm, false)) < 0)
        goto cleanup;") :which-func "qemuProcessStart")) :annotation-list ((annotation :type text :data "ここでログファイル名を決めている。")) :date "Thu Apr  5 15:00:33 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/qemu/qemu_process.c" :point 93226 :coding-system undecided-unix :line 3024 :surround ("
" "" "    if ((pos = lseek(logfile, 0, SEEK_END)) < 0)
        VIR_WARN(\"Unable to seek to end of logfile: %s\",") :which-func "qemuProcessStart")) :annotation-list ((annotation :type text :data "ログファイル末尾にシークして")) :date "Thu Apr  5 15:00:53 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/libvirt/0.9.4-23.el6/pre-build/libvirt-0.9.4/src/util/command.c" :point 12635 :coding-system undecided-unix :line 452 :surround ("    }
" "" "    if (childerr > 0 && prepareStdFd(childerr, STDERR_FILENO) < 0) {
        virReportSystemError(errno,") :which-func "virExecWithHook")) :annotation-list ((annotation :type text :data "標準エラー出力を差し替えている=>ログファイルへ。")) :date "Thu Apr  5 15:05:21 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/q/qemu-kvm/0.12.1.2-2.209.el6/pre-build/qemu-kvm-0.12.1.2/hw/wdt_i6300esb.c" :point 6042 :coding-system undecided-unix :line 181 :surround ("        /* What to do at the end of stage 1? */
" "" "        switch (d->int_type) {
        case INT_TYPE_IRQ:") :which-func "i6300esb_timer_expired")) :annotation-list ((annotation :type text :data "libvirtがqemuをexecveする前にstderrの配管工事をしているため
ログファイル(/var/log/libvirt/qemu/ゲストの名前.log)へ記載される。")) :date "Thu Apr  5 15:06:37 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/q/qemu-kvm/0.12.1.2-2.209.el6/pre-build/qemu-kvm-0.12.1.2/hw/watchdog.c" :point 2568 :coding-system undecided-unix :line 85 :surround ("{
" "" "    if (strcasecmp(p, \"reset\") == 0)
        watchdog_action = WDT_RESET;") :which-func "select_watchdog_action")) :annotation-list ((annotation :type text :data "watchdog_actionはqemuの引数-watchdog-actionで与える。(man qemu)")) :date "Thu Apr  5 15:09:04 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-watchdog))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.32-220.el6/pre-build/kernel-2.6.32-220.el6/linux-2.6.32-220.el6.x86_64/net/core/dev.c" :point 72999 :coding-system undecided-unix :line 2777 :surround ("#ifdef CONFIG_NET_CLS_ACT
" "" "	skb = handle_ing(skb, &pt_prev, &ret, orig_dev);
	if (!skb)") :which-func "__netif_receive_skb")) :annotation-list ((annotation :type text :data "CPU毎のinput_pkt_queue 
-> ソケット単位のsk_receive_queue
あるいは
-> handle_ingの先のqdisc")) :date "Fri Apr  6 01:36:57 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-udp))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/^alias-rhel5su8/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/drivers/md/dm-mpath.c" :point 30803 :coding-system undecided-unix :line 1377 :surround ("
" "" "	if (hwh->type && hwh->type->error)
		err_flags = hwh->type->error(hwh, bio);") :which-func "do_end_io")) :annotation-list ((annotation :type text :data "hardwareハンドラにエラーかどうか再解釈の余地を与えている。")) :date "Wed May 16 00:41:40 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/^alias-rhel5su8/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/drivers/md/dm-mpath.c" :point 34501 :coding-system undecided-unix :line 1508 :surround ("
" "" "	if (hwh->type && hwh->type->status)
		sz += hwh->type->status(hwh, type, result + sz, maxlen - sz);") :which-func "multipath_status")) :annotation-list ((annotation :type text :data "ハードウェアハンドラ特有の情報を載せる余地を与える。")) :date "Wed May 16 00:42:40 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/s/squid/3.1.10-1.el6_2.2/pre-build/squid-3.1.10/src/peer_digest.cc" :point 17671 :coding-system undecided-unix :line 594 :surround ("            /* some kind of a bug */
" "" "            peerDigestFetchAbort(fetch, buf, httpStatusLineReason(&reply->sline));
            return -1;		/* XXX -1 will abort stuff in ReadReply! */") :which-func "peerDigestFetchReply")) :annotation-list ((annotation :type text :data "ここからエラーメッセージへ")) :date "Fri May 18 19:02:19 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-squid3))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/drivers/scsi/scsi_error.c" :point 8165 :coding-system undecided-unix :line 309 :surround (" **/
" "" "static int scsi_check_sense(struct scsi_cmnd *scmd)
{") :which-func "scsi_check_sense")) :annotation-list ((annotation :type text :data "sense == error code
http://en.wikipedia.org/wiki/SCSI_Request_Sense_Command")) :date "Wed May 23 13:54:34 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/drivers/scsi/scsi_error.c" :point 8543 :coding-system undecided-unix :line 321 :surround ("
" "" "	if (scsi_dh_data && scsi_dh_data->scsi_dh &&
			scsi_dh_data->scsi_dh->check_sense) {") :which-func "scsi_check_sense")) :annotation-list ((annotation :type text :data "scsi device handlerがあれば、そこで

      sense -> linuxのscsi層で定義されたエラーコード

への変換を行う。なければ汎用のコードでがんばる。")) :date "Wed May 23 13:55:07 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/fs/buffer.c" :point 38271 :coding-system undecided-unix :line 1391 :surround ("	if (!test_set_buffer_dirty(bh))
" "" "		__set_page_dirty_nobuffers(bh->b_page);
}") :which-func "mark_buffer_dirty")) :annotation-list ((annotation :type text :data "buffer_headがdirtyになれば、それにぶらさがるページもdirtyにする。")) :date "Mon May 28 22:30:30 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ext3-journal))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/fs/jbd/transaction.c" :point 35845 :coding-system undecided-unix :line 1161 :surround ("
" "" "	set_buffer_jbddirty(bh);
") :which-func "journal_dirty_metadata")) :annotation-list ((annotation :type text :data "mark_buffer_dirtyと同じように別のカーネルスレッドで
処理されるようマークを打っているのでは？")) :date "Mon May 28 22:58:14 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ext3-journal))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/fs/jbd/commit.c" :point 18623 :coding-system undecided-unix :line 646 :surround ("				bh->b_end_io = journal_end_buffer_io_sync;
" "" "				submit_bh(WRITE, bh);
			}") :which-func "journal_commit_transaction")) :annotation-list ((annotation :type text :data "mark_buffer_dirtyとして(ページキャッシュ側の仕掛けである)pdflushに
書き込みを委託するのではなく、自分でsubmit_bh、すなわちbioへのbhのフラッシュ
の依頼をしている。")) :date "Tue May 29 00:22:04 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ext3-journal))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/fs/ext3/super.c" :point 59609 :coding-system undecided-unix :line 2058 :surround ("
" "" "	if (journal_inum) {
		if (!(journal = ext3_get_journal(sb, journal_inum)))") :which-func "ext3_load_journal")) :annotation-list ((annotation :type text :data "journalファイルかデバイスによって分岐")) :date "Tue May 29 02:44:08 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ext3-journal))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/fs/jbd/commit.c" :point 19439 :coding-system undecided-unix :line 674 :surround ("	 */
" "" "wait_for_iobuf:
	while (commit_transaction->t_iobuf_list != NULL) {") :which-func "journal_commit_transaction")) :annotation-list ((annotation :type text :data "journal_write_metadata_buffer経由でt_iobuf_listにつながれる。")) :date "Tue May 29 03:15:44 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ext3-journal))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/fs/jbd/commit.c" :point 21285 :coding-system undecided-unix :line 735 :surround ("	/* Here we wait for the revoke record and descriptor record buffers */
" "" " wait_for_ctlbuf:
	while (commit_transaction->t_log_list != NULL) {") :which-func "journal_commit_transaction")) :annotation-list ((annotation :type text :data "journal_write_revoke_records経由でt_log_listにつながれる。")) :date "Tue May 29 03:17:05 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ext3-journal))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/fs/jbd/commit.c" :point 21941 :coding-system undecided-unix :line 764 :surround ("
" "" "	if (journal_write_commit_record(journal, commit_transaction))
		err = -EIO;") :which-func "journal_commit_transaction")) :annotation-list ((annotation :type text :data "journalが書けたこと、すなわちcommitが完了したことをディスクに同期書き込みする。")) :date "Tue May 29 03:20:17 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ext3-journal))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/fs/jbd/commit.c" :point 24920 :coding-system undecided-unix :line 851 :surround ("			JBUFFER_TRACE(jh, \"add to new checkpointing trans\");
" "" "			__journal_insert_checkpoint(jh, commit_transaction);
			if (is_journal_aborted(journal))") :which-func "journal_commit_transaction")) :annotation-list ((annotation :type text :data "ジャーナルをコミットしたので、次に通常の書き出しを行うためにcheckpointリストににつなぐ。")) :date "Tue May 29 03:37:58 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ext3-journal))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/fs/jbd/commit.c" :point 25100 :coding-system undecided-unix :line 855 :surround ("			JBUFFER_TRACE(jh, \"refile for checkpoint writeback\");
" "" "			__journal_refile_buffer(jh);
			jbd_unlock_bh_state(bh);") :which-func "journal_commit_transaction")) :annotation-list ((annotation :type text :data "ここでt_reserved_listへ連結される。")) :date "Tue May 29 03:39:50 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ext3-journal))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/fs/jbd/checkpoint.c" :point 13253 :coding-system undecided-unix :line 475 :surround ("
" "" "	journal->j_free += freed;
	journal->j_tail_sequence = first_tid;") :which-func "cleanup_journal_tail")) :annotation-list ((annotation :type text :data "チェックポイントの書き出しまで完了したら、journal系の状態をディスクに書き出す?")) :date "Tue May 29 04:01:58 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ext3-journal))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/^alias-rhel5su6/pre-build/cman-2.0.115/cman/qdisk/main.c" :point 20288 :coding-system undecided-unix :line 852 :surround ("	FD_SET(fd, &rfds);
" "" "	if (select(fd + 1, &rfds, NULL, NULL, &tv) == 1) {
		if (cman_dispatch(ch, CMAN_DISPATCH_ALL) < 0) {") :which-func "cman_alive")) :annotation-list ((annotation :type text :data "タイムアウトした場合0")) :date "Fri Jun  1 12:46:17 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-qdisk))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/^alias-rhel5su6/pre-build/cman-2.0.115/cman/qdisk/main.c" :point 13981 :coding-system undecided-unix :line 576 :surround (" */
" "" "void
check_cman(qd_ctx *ctx, memb_mask_t mask, memb_mask_t master_mask)") :which-func "do_vote")) :annotation-list ((annotation :type text :data "maskは定期的にqdiskを読んで得られた各ノードの死活に関する自ノードのビュー。
master_maskはそれと自ノードで動くcmanから得られた死活の情報の積。")) :date "Fri Jun  1 12:50:51 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-qdisk))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/^alias-rhel5su6/pre-build/cman-2.0.115/cman/qdisk/main.c" :point 25729 :coding-system undecided-unix :line 1053 :surround ("			   online.  If we are, tell CMAN so. */
" "" "			if (is_bit_set(
			      ni[ctx->qc_master-1].ni_status.ps_master_mask,") :which-func "quorum_loop")) :annotation-list ((annotation :type text :data "masterがqdiskから読んで対象ノードが生きているか、master上のcmanが対象ノードが生きていると言っているか
両方みたしていることが読めたらvoteを維持。ただし!maser_winsの場合。")) :date "Fri Jun  1 12:52:58 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-qdisk))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/^alias-rhel5su6/pre-build/cman-2.0.115/cman/qdisk/main.c" :point 21544 :coding-system undecided-unix :line 902 :surround ("
" "" "		/* Check for node transitions */
		check_transitions(ctx, ni, max, mask);") :which-func "quorum_loop")) :annotation-list ((annotation :type text :data "応答のないノードはここでkillする。")) :date "Fri Jun  1 12:55:38 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-qdisk))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/^alias-rhel5su6/pre-build/cman-2.0.115/cman/qdisk/main.c" :point 28817 :coding-system undecided-unix :line 1151 :surround ("
" "" "		if (errors && ctx->qc_max_error_cycles) {
			++error_cycles;") :which-func "quorum_loop")) :annotation-list ((annotation :type text :data "書き込みに失敗してかつ/cluster/quorumd/@max_error_cyclesが設定されて
いる場合、exit。")) :date "Fri Jun  1 13:05:31 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-qdisk))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/^alias-rhel5su6/pre-build/cman-2.0.115/cman/qdisk/main.c" :point 20464 :coding-system undecided-unix :line 863 :surround ("
" "" "int
quorum_loop(qd_ctx *ctx, node_info_t *ni, int max)") :which-func "cman_alive")) :annotation-list ((annotation :type text :data "概要:
1. read_node_blocks: 読み込み、自分がEVICTEDであればリブート
2. check_transitions: 読み込んだデータを見て活動が止っていればevict & fence
3. score処理
4. master_exists: masterの存在確認
4.1 不在の場合: 入札
4.1.1 自分が若いノード番号を持てば、入札開始(M_BID)、masterへ立候補
4.1.2 自分が立候補しない場合、立候補したノードに同意(M_ACK)
4.2 存在する場合： voteの更新
4.2.1 cman_poll_quorum_device: 自分がmasterであればvoteを更新
4.2.2 (MASTER_WINSの場合)自分がmasterでなければ何もしない。
5. 書き込み")) :date "Fri Jun  1 12:56:13 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-qdisk))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cman/^alias-rhel5su6/pre-build/cman-2.0.115/cman/qdisk/disk.h" :point 1653 :coding-system undecided-unix :line 53 :surround ("
" "" "typedef enum {
	M_NONE  = 0x0,"))) :annotation-list ((annotation :type text :data "入札用のメッセージ
qdisk上で交換する。")) :date "Fri Jun  1 13:10:07 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-qdisk))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/0.4.7-48.el5/pre-build/multipath-tools-0.4.7.rhel5.32/libmultipath/discovery.c" :point 1987 :coding-system undecided-unix :line 99 :surround ("
" "" "static int
path_discover (vector pathvec, struct config * conf, char * devname, int flag)") :which-func "device_ok_to_add")) :annotation-list ((annotation :type text :data "/sys/block/*/deviceをさがす。")) :date "Tue Jun  5 11:38:52 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/lvm2/2.02.84-6.el5/pre-build/LVM2.2.02.84/libdm/libdevmapper.h" :point 2221 :coding-system undecided-unix :line 76 :surround ("int dm_log_is_non_default(void);
" "" "
enum {") :which-func "\"C\"")) :annotation-list ((annotation :type text :data "ioctl/libdm-iface.c対応するioctl命令がある。")) :date "Tue Jun  5 22:00:17 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/^alias-rhel5su8/pre-build/multipath-tools-0.4.7.rhel5.32/multipathd/main.c" :point 26443 :coding-system undecided-unix :line 1232 :surround ("	}
" "" "	if (map_discovery(vecs))
		return 1;") :which-func "configure")) :annotation-list ((annotation :type text :data "libdmを使ってカーネルに問合せてすでに構成されているmultipathデバイスがあればその情報を得る。")) :date "Tue Jun  5 22:07:37 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/^alias-rhel5su8/pre-build/multipath-tools-0.4.7.rhel5.32/multipathd/main.c" :point 26546 :coding-system undecided-unix :line 1238 :surround ("	 */
" "" "	if (coalesce_paths(vecs, mpvec, NULL))
		return 1;") :which-func "configure")) :annotation-list ((annotation :type text :data "新規のmultipahデバイスを登録する？")) :date "Tue Jun  5 22:09:02 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/0.4.7-48.el5/pre-build/multipath-tools-0.4.7.rhel5.32/libmultipath/uevent.c" :point 1609 :coding-system undecided-unix :line 50 :surround ("pthread_cond_t  uev_cond,  *uev_condp  = &uev_cond;
" "" "uev_trigger *my_uev_trigger;
void * my_trigger_data;"))) :annotation-list ((annotation :type text :data "なぜ大域変数なのか？")) :date "Tue Jun 12 03:29:44 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cluster/3.0.12-41.el6/pre-build/cluster-3.0.12/group/gfs_controld/util.c" :point 3359 :coding-system undecided-unix :line 173 :surround ("		else
" "" "			send_withdraw(mg);
	}") :which-func "dmsetup_suspend_done")) :annotation-list ((annotation :type text :data "異常が検出されるとueventが飛ぶ。
gfs_controldはそれを受信して

	dmsetup suspend

する。それが成功すると同じ mountgroup に参加する
他のgfs_controldにそのことを通知する。")) :date "Sat Jun 16 00:41:19 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-gfs2-withdrawn))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cluster/3.0.12-41.el6/pre-build/cluster-3.0.12/group/gfs_controld/cpg-new.c" :point 67607 :coding-system undecided-unix :line 2605 :surround ("				/* no one remaining to send us an ack */
" "" "				set_sysfs(mg, \"withdraw\", 1);
				free_mg(mg);") :which-func "confchg_cb")) :annotation-list ((annotation :type text :data "   . C gets OOB message and set /sys/fs/gfs/foo/withdraw to 1")) :date "Sat Jun 16 04:37:59 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-gfs2-withdrawn))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/cluster/3.0.12-41.el6/pre-build/cluster-3.0.12/group/gfs_controld/cpg-new.c" :point 21074 :coding-system undecided-unix :line 892 :surround ("
" "" "	stop_kernel(mg);
") :which-func "wait_conditions_done")) :annotation-list ((annotation :type text :data "   . A,B stop kernel foo")) :date "Sat Jun 16 04:54:21 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-gfs2-withdrawn))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/0.4.7-48.el5/pre-build/multipath-tools-0.4.7.rhel5.32/multipathd/main.c" :point 5305 :coding-system undecided-unix :line 257 :surround ("	
" "" "	map_present = dm_map_present(alias);
") :which-func "ev_add_map")) :annotation-list ((annotation :type text :data "kernelが知っているか。")) :date "Wed Jun 20 22:01:44 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/0.4.7-48.el5/pre-build/multipath-tools-0.4.7.rhel5.32/multipathd/main.c" :point 5482 :coding-system undecided-unix :line 265 :surround ("
" "" "	mpp = find_mp_by_alias(vecs->mpvec, alias);
") :which-func "ev_add_map")) :annotation-list ((annotation :type text :data "自分(multipathd)は知っているか。")) :date "Wed Jun 20 22:02:21 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-308.el5/pre-build/kernel-2.6.18/linux-2.6.18-308.el5.x86_64/include/net/tcp.h" :point 3582 :coding-system undecided-unix :line 126 :surround ("#define TCP_RTO_MAX	((unsigned)(120*HZ))
" "" "#define TCP_RTO_MIN	((unsigned)(HZ/5))
#define TCP_TIMEOUT_INIT ((unsigned)(3*HZ))	/* RFC 1122 initial RTO value	*/") :which-func "TCP_RTO_MIN")) :annotation-list ((annotation :type text :data "connectのとき200msで再送することはある。")) :date "Fri Jun 29 09:15:12 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-tcp-rto))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-194.el5/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/drivers/md/dm.c" :point 14219 :coding-system undecided-unix :line 697 :surround ("
" "" "	ti = dm_table_find_target(ci->map, ci->sector);
	if (!dm_target_is_valid(ti))") :which-func "__clone_and_map")) :annotation-list ((annotation :type text :data "sectorが決まったところで(pvに対応する)tiも決まる。")) :date "Tue Jul  3 10:39:10 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-lvm))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/2.6.18-194.el5/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/drivers/md/dm.c" :point 14219 :coding-system undecided-unix :line 697 :surround ("
" "" "	ti = dm_table_find_target(ci->map, ci->sector);
	if (!dm_target_is_valid(ti))") :which-func "__clone_and_map")) :annotation-list ((annotation :type text :data "lvcreateした時に与えられるブロックデバイスとそのレンジから
mapping(sectorからブロックデバイスへの対応関係は決まる？)")) :date "Tue Jul  3 10:41:48 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-lvm))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/l/lvm2/2.02.88-7.el5/pre-build/LVM2.2.02.88/tools/lvresize.c" :point 19316 :coding-system undecided-unix :line 736 :surround ("
" "" "	if (!suspend_lv(cmd, lock_lv)) {
		log_error(\"Failed to suspend %s\", lp->lv_name);") :which-func "_lvresize")) :annotation-list ((annotation :type text :data "ここで カーネル内でfsfreeze相当の処理が実施された後

       struct mapped_device *md;
       md->suspended_bdev = xxx
       
が設定される。この後の処理で、ブロックデバイスのサイズの読み直しが発生する。
md->suspended_bdevがnon-zeroであることが読み直しできる条件。")) :date "Wed Jul  4 03:05:57 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-lvm))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper/1.02.67-2.el5/pre-build/device-mapper.1.02.67/LVM2.2.02.88/libdm/ioctl/libdm-iface.c" :point 40124 :coding-system undecided-unix :line 1753 :surround ("
" "" "	switch (dmt->type) {
	case DM_DEVICE_CREATE:") :which-func "dm_task_run")) :annotation-list ((annotation :type text :data "自分でmknodしてる。")) :date "Thu Jul 12 03:35:27 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/0.4.7-48.el5/pre-build/multipath-tools-0.4.7.rhel5.32/multipathd/main.c" :point 9681 :coding-system undecided-unix :line 469 :surround ("	}
" "" "	dm_lib_release();
") :which-func "ev_add_path")) :annotation-list ((annotation :type text :data "やりかけのノードノード群、作成、消去作業があれば実行する？")) :date "Thu Jul 12 03:38:53 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/0.4.7-48.el5/pre-build/multipath-tools-0.4.7.rhel5.32/multipathd/main.c" :point 9300 :coding-system undecided-unix :line 453 :surround ("	 */
" "" "	if (domap(mpp) <= 0) {
		condlog(0, \"%s: failed in domap for addition of new \"") :which-func "ev_add_path")) :annotation-list ((annotation :type text :data "すなわちdm_task_run")) :date "Thu Jul 12 03:43:02 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/0.4.7-48.el5/pre-build/multipath-tools-0.4.7.rhel5.32/multipathd/main.c" :point 3440 :coding-system undecided-unix :line 177 :surround ("				continue;
" "" "			if ((pp->dmstate == PSTATE_FAILED ||
			     pp->dmstate == PSTATE_UNDEF) &&") :which-func "sync_map_state")) :annotation-list ((annotation :type text :data "state: checker
dmstate: dm.ko")) :date "Thu Jul 12 03:46:10 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/0.4.7-48.el5/pre-build/multipath-tools-0.4.7.rhel5.32/multipathd/main.c" :point 9774 :coding-system undecided-unix :line 474 :surround ("	 */
" "" "	if (setup_multipath(vecs, mpp))
		goto out;") :which-func "ev_add_path")) :annotation-list ((annotation :type text :data "カーネルからカーネル側の状態を読み出す？")) :date "Thu Jul 12 03:56:07 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/d/device-mapper-multipath/0.4.7-48.el5/pre-build/multipath-tools-0.4.7.rhel5.32/multipathd/main.c" :point 9820 :coding-system undecided-unix :line 477 :surround ("
" "" "	sync_map_state(mpp);
") :which-func "ev_add_path")) :annotation-list ((annotation :type text :data "mapは存在するとして、enable, disable.")) :date "Thu Jul 12 04:32:26 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-multipath))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/^alias-rhel5su4/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/net/ipv6/ndisc.c" :point 30276 :coding-system undecided-unix :line 1196 :surround ("
" "" "static void ndisc_router_discovery(struct sk_buff *skb)
{") :which-func "ndisc_router_discovery")) :annotation-list ((annotation :type text :data "RAの受信処理")) :date "Thu Jul 12 12:13:30 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ipv6-ra))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/k/kernel/^alias-rhel5su4/pre-build/kernel-2.6.18/linux-2.6.18.x86_64/net/ipv6/addrconf.c" :point 10320 :coding-system undecided-unix :line 373 :surround ("	ndev->dev = dev;
" "" "	memcpy(&ndev->cnf, &ipv6_devconf_dflt, sizeof(ndev->cnf));
	if (ext != NULL) {") :which-func "ipv6_add_dev")) :annotation-list ((annotation :type text :data "\"default\"は追加になったデバイスの初期値に使う。")) :date "Thu Jul 12 12:19:45 2012" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-ipv6-ra))
