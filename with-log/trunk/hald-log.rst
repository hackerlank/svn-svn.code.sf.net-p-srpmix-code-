環境変数HALD_VERBOSEに何かをセットうるか、hald起動時に--verbose=yes
stderrに出る。stderrに出るものは--daemon=noでおさえる。

/sbin/serviceでやるとstderrに出ない。syslogに出てる。

まったく別の系統(syslog)でsyslogに出るものがある。


enum {
	HAL_LOGPRI_TRACE = (1 << 0),   /**< function call sequences */
	HAL_LOGPRI_DEBUG = (1 << 1),   /**< debug statements in code */
	HAL_LOGPRI_INFO = (1 << 2),    /**< informational level */
	HAL_LOGPRI_WARNING = (1 << 3), /**< warnings */
	HAL_LOGPRI_ERROR = (1 << 4)    /**< error */
};

のうちHAL_LOGPRI_TRACE以外は出る。
