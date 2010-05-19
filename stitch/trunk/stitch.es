;; -*- scheme -*-
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 60432 :coding-system undecided-unix :line 2152 :which-func ("totemsrp_mcast"))) :annotation-list ((annotation :type text :data "ここでキューに入れる。トークンが回ってきて送信許可を得たときに送信できる(orf_token_mcast)。")) :date "Mon Nov 16 01:18:35 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 7871 :coding-system undecided-unix :line 276 :surround ("
" "" "struct message_item {
	struct mcast *mcast;") :which-func ("message_item"))) :annotation-list ((annotation :type text :data "message_itemとsort_queue_itemは同じ構造を持つ。")) :date "Mon Nov 16 01:46:22 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemconfig.c" :point 8802 :coding-system undecided-unix :line 297 :surround ("
" "" "	strcpy (totem_config->rrp_mode, \"none\");
") :which-func ("totem_config_read"))) :annotation-list ((annotation :type text :data "active,passive,noneからデフォルトはnone。")) :date "Mon Nov 16 02:16:02 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/attic/cradles/lcopy.sys/mirror/c/corosync/trunk/pre-build/trunk/exec/totemudp.c" :point 49674 :coding-system undecided-unix :line 1875 :surround ("
" "" "int totemudp_mcast_noflush_send (
	void *udp_context,") :which-func ("totemudp_mcast_noflush_send"))) :annotation-list ((annotation :type text :data "threadsがonの場合キューに入るが、そうでなければ、totemudp_mcast_flush_sendと同じ。")) :date "Mon Nov 16 02:18:29 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 94805 :coding-system undecided-unix :line 3409 :surround ("	case MEMB_STATE_OPERATIONAL:
" "" "		messages_free (instance, token->aru);
	case MEMB_STATE_GATHER:") :which-func ("message_handler_orf_token"))) :annotation-list ((annotation :type text :data "fall through?")) :date "Mon Nov 16 02:29:42 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 99934 :coding-system undecided-unix :line 3569 :surround ("
" "" "			totemrrp_send_flush (instance->totemrrp_context);
			token_send (instance, token, forward_token);") :which-func ("if"))) :annotation-list ((annotation :type text :data "threadを使っている場合、ワークキューが空になるのを待つ。")) :date "Mon Nov 16 02:31:46 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 99987 :coding-system undecided-unix :line 3570 :surround ("			totemrrp_send_flush (instance->totemrrp_context);
" "" "			token_send (instance, token, forward_token);
") :which-func ("if"))) :annotation-list ((annotation :type text :data "次の人にトークンを渡す。")) :date "Mon Nov 16 02:32:23 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 75711 :coding-system undecided-unix :line 2752 :surround ("
" "" "static void memb_state_commit_token_target_set (
	struct totemsrp_instance *instance)") :which-func ("memb_state_commit_token_target_set"))) :annotation-list ((annotation :type text :data "トークンを受けとる人一覧をセットしている？")) :date "Mon Nov 16 02:35:32 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
(stitch-annotation :version 0 :target-list ((target :type file :file "/srv/sources/sources/c/corosync/^lcopy-trunk/pre-build/trunk/exec/totemsrp.c" :point 75914 :coding-system undecided-unix :line 2760 :surround ("
" "" "	for (i = 0; i < instance->totem_config->interface_count; i++) {
		totemrrp_token_target_set (") :which-func ("memb_state_commit_token_target_set"))) :annotation-list ((annotation :type text :data "interfaceでループ")) :date "Mon Nov 16 02:48:13 2009" :full-name "Masatake YAMATO" :mailing-address "yamato@redhat.com" :keywords (reading-corosync))
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
