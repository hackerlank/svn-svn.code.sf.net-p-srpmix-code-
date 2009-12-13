#include <sys/time.h>
#include <sys/ioctl.h>
#include <sys/types.h>
#include <linux/types.h>
#include <stdio.h>


#include <sys/stat.h>
#include <unistd.h>
#include <errno.h>
#include <fcntl.h>

/*
 * The event structure itself
 */

struct input_event {
	struct timeval time;
	__u16 type;
	__u16 code;
	__s32 value;
};


int
main(int argc, char** argv)
{
  int fd;
  struct input_event ev;


  if (argc != 2)
    {
      return 1;
    }


  fd = open(argv[1], O_RDWR | 0 /*O_NONBLOCK*/, 0);
  
  if (fd < 0)
    {
      perror(argv[1]);
      return 1;
    }

  while (1)
    {
      read(fd, &ev, sizeof(ev));
      printf("type: %u, type: %u, value: %d\n",
	     ev.type, ev.code, ev.value);
    }
  return 0;
}
