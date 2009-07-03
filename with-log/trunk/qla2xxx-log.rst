int ql2xextended_error_logging;
module_param(ql2xextended_error_logging, int, S_IRUGO|S_IRUSR);
MODULE_PARM_DESC(ql2xextended_error_logging,
		"Option to enable extended error logging, "
		"Default is 0 - no logging. 1 - log errors.");



module_param(scsi_logging_level, int, S_IRUGO|S_IWUSR);
MODULE_PARM_DESC(scsi_logging_level, "a bit mask of logging levels");
