/**
   Copyright Red Hat, Inc. 2006
   Copyright Masatake YAMATO 2009

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any
   later version.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; see the file COPYING.  If not, write to the
   Free Software Foundation, Inc.,  675 Mass Ave, Cambridge, 
   MA 02139, USA.

   Author: Masatake YAMATO <yamato@redhat.com>
   Derived from disk.h of cman-2.0.98/cman/qdisk

   disk.h is written by Lon Hohberger <lhh at redhat.com>.
*/

#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>		/* for valloc */
#include <unistd.h>
#include <getopt.h>
#include <string.h>

#include <sys/types.h>
#include <sys/stat.h>

#define __USE_GNU
#include <fcntl.h>

#include <sys/ioctl.h>

#include <linux/fs.h>

#include <alloca.h>
#include <linux/swab.h>

/*
  Copyright Red Hat, Inc. 2002-2003

  The Red Hat Cluster Manager API Library is free software; you can
  redistribute it and/or modify it under the terms of the GNU Lesser
  General Public License as published by the Free Software Foundation;
  either version 2.1 of the License, or (at your option) any later
  version.

  The Red Hat Cluster Manager API Library is distributed in the hope
  that it will be useful, but WITHOUT ANY WARRANTY; without even the
  implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
  PURPOSE.  See the GNU Lesser General Public License for more details.

  You should have received a copy of the GNU Lesser General Public
  License along with this library; if not, write to the Free Software
  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
  USA. 
*/
/** @file
 * Defines for byte-swapping
 */
#ifndef __PLATFORM_H
#define __PLATFORM_H

#include <endian.h>
#include <sys/param.h>
#include <byteswap.h>
#include <bits/wordsize.h>

/* No swapping on little-endian machines */
#if __BYTE_ORDER == __LITTLE_ENDIAN
#define le_swap16(x) (x)
#define le_swap32(x) (x)
#define le_swap64(x) (x)
#else
#define le_swap16(x) bswap_16(x)
#define le_swap32(x) bswap_32(x)
#define le_swap64(x) bswap_64(x)
#endif

/* No swapping on big-endian machines */
#if __BYTE_ORDER == __LITTLE_ENDIAN
#define be_swap16(x) bswap_16(x)
#define be_swap32(x) bswap_32(x)
#define be_swap64(x) bswap_64(x)
#else
#define be_swap16(x) (x)
#define be_swap32(x) (x)
#define be_swap64(x) (x)
#endif


#define swab16(x) x=be_swap16(x)
#define swab32(x) x=be_swap32(x)
#define swab64(x) x=be_swap64(x)


#endif /* __PLATFORM_H */


#define MAX_NODES_DISK		16	
#define MEMB_MASK_LEN           ((MAX_NODES_DISK / 8) +		\
				 (!!(MAX_NODES_DISK % 8)))
#define DISK_MEMB_MASK_LEN	((MEMB_MASK_LEN + 7) & ~7)

typedef uint8_t memb_mask_t [DISK_MEMB_MASK_LEN];
typedef struct __attribute__ ((packed)) {
  uint32_t	ps_magic;
  /* 4 */
  uint32_t	ps_updatenode;		// Last writer
  /* 8 */
  uint64_t	ps_timestamp;		// time of last update
  /* 16 */
  uint32_t	ps_nodeid;
  uint32_t	pad0;
  /* 24 */
  uint8_t		ps_state;		// running or stopped
  uint8_t		pad1[1];
  uint16_t	ps_flags;
  /* 26 */
  uint16_t	ps_score;		// Local points
  uint16_t	ps_scoremax;		// What we think is our max
  // points, if other nodes
  // disagree, we may be voted
  // out
  /* 28 */
  uint32_t	ps_ca_sec;		// Cycle speed (average)
  uint32_t	ps_ca_usec;
  /* 36 */
  uint32_t	ps_lc_sec;		// Cycle speed (last)
  uint32_t	ps_lc_usec;
  uint64_t	ps_incarnation;		// Token to detect hung +
  // restored node
  /* 44 */
  uint16_t	ps_msg;			// Vote/bid mechanism 
  uint16_t	ps_seq;
  uint32_t	ps_arg;
  /* 52 */
  memb_mask_t	ps_mask;		// Bitmap
  memb_mask_t	ps_master_mask;		// Bitmap
  /* 60 */
} status_block_t;
#define swab_status_block_t(ptr)		\
  {						\
    swab32((ptr)->ps_magic);			\
    swab32((ptr)->ps_updatenode);		\
    swab64((ptr)->ps_timestamp);		\
    swab32((ptr)->ps_nodeid);			\
    swab32((ptr)->pad0);			\
    /* state + pad */				\
    swab16((ptr)->ps_flags);			\
    swab16((ptr)->ps_score);			\
    swab16((ptr)->ps_scoremax);			\
    /* Cycle speeds */				\
    swab32((ptr)->ps_ca_sec);			\
    swab32((ptr)->ps_ca_usec);			\
    swab32((ptr)->ps_lc_sec);			\
    swab32((ptr)->ps_lc_usec);			\
    /* Message */				\
    swab16((ptr)->ps_msg);			\
    swab16((ptr)->ps_seq);			\
    swab32((ptr)->ps_arg);			\
  }

typedef enum {
  S_NONE  = 0x0,		// Shutdown / not quorate / not running
  S_EVICT	= 0x1,		// Voted out / about to be fenced.
  /* ^^^ Fencing OK */
  S_INIT	= 0x2,		// Initializing.  Hold your fire.
  /* vvv Fencing will kill a node */
  S_RUN	= 0x5,		// I think I'm running.
  S_MASTER= 0x6		// I know I'm running, and have advertised to
  // CMAN the availability of the disk vote for my
  // partition.
} disk_node_state_t;


typedef enum {
  M_NONE  = 0x0,
  M_BID	= 0x1,
  M_ACK	= 0x2,
  M_NACK	= 0x3,
  M_MASK	= 0x4
} disk_msg_id_t;

typedef struct __attribute__ ((packed)) {
  uint32_t h_magic;		/* Header magic	       */
  uint32_t h_hcrc;		/* Header CRC          */
  uint32_t h_dcrc;		/* CRC32 of data       */
  uint32_t h_length;		/* Length of real data */
  uint64_t h_view;		/* View # of real data */
  uint64_t h_timestamp;		/* Timestamp           */
} shared_header_t;
#define swab_shared_header_t(ptr)		\
  {						\
    swab32((ptr)->h_magic);			\
    swab32((ptr)->h_hcrc);			\
    swab32((ptr)->h_dcrc);			\
    swab32((ptr)->h_length);			\
    swab64((ptr)->h_view);			\
    swab64((ptr)->h_timestamp);			\
  }

#define SHARED_HEADER_MAGIC	0x00DEBB1E	/* Per-block headeer */



typedef struct __attribute__ ((packed)) {
  uint32_t	qh_magic;
  uint32_t	qh_version;	   // 
  uint64_t	qh_timestamp;	   // time of last update
  char 		qh_updatehost[128];// Hostname who put this here...
  char		qh_cluster[120];   // Cluster name; CMAN only 
  // supports 16 chars.
  uint32_t	qh_blksz;          // Known block size @ creation
  uint32_t	qh_kernsz;	   // Ingored
} quorum_header_t;
#define swab_quorum_header_t(ptr)		\
  {						\
    swab32((ptr)->qh_magic);			\
    swab32((ptr)->qh_version);			\
    swab32((ptr)->qh_blksz);			\
    swab32((ptr)->qh_kernsz);			\
    swab64((ptr)->qh_timestamp);		\
  }
#define HEADER_MAGIC_NUMBER	0xeb7a62c2	/* Partition header */


void
print_usage(char* progname, FILE* stream)
{
  fprintf(stream, "Usage: \n");
  fprintf(stream, "	%s -h\n", progname);
  fprintf(stream, "	%s DEVICE|FILE\n", progname);
}

int
process_shared_header(char* buf, int i)
{
  shared_header_t *hdrp;

  hdrp = (shared_header_t *)buf;

  if (hdrp->h_magic != SHARED_HEADER_MAGIC)
    swab_shared_header_t(hdrp);

  printf("SHARED HEADER[%d]\n", i);
  printf("Header magic: 0x%08x\n", hdrp->h_magic);
  if (hdrp->h_magic == 0)
    {
      return 0;
    }
  else if (hdrp->h_magic != SHARED_HEADER_MAGIC)
    {
      fprintf(stderr, "Unknown header magic 0x%08x\n", hdrp->h_magic);
      fprintf(stderr, "Exepcted value 0x%08x\n",       SHARED_HEADER_MAGIC);
      return 5;
    }
  
  printf("Header CRD: 0x%08x\n", hdrp->h_hcrc);
  printf("CRC32 of data: 0x%08x\n", hdrp->h_dcrc);
  printf("Length of real data: %u\n", hdrp->h_length);
  printf("View # of real data: %lu\n", hdrp->h_view);
  printf("Timestamp: %lu\n", hdrp->h_timestamp);

  return 0;
}

int
process_quorum_header(char* buf)
{
  quorum_header_t* qh;
  int i;


  printf("QUORUM HEADER\n");

  qh = (quorum_header_t*)(buf + sizeof(shared_header_t));
  swab_quorum_header_t(qh);
  printf("Quorum header magic: 0x%08x\n", qh->qh_magic);
  if (qh->qh_magic != HEADER_MAGIC_NUMBER)
    {
      fprintf(stderr, "Unknown quorum header magic 0x%08x\n", qh->qh_magic);
      fprintf(stderr, "Exepcted value 0x%08x\n",              HEADER_MAGIC_NUMBER);
    }
  printf("Quorum header version: 0x%08x\n", qh->qh_version);
  printf("time of last update: %lu\n", qh->qh_timestamp);
  printf("Hostname who put this here...: ");
  for (i = 0; i < 128; i++)
    printf("%c", qh->qh_updatehost[i]);
  printf("\n");

  printf("Cluster name; CMAN only(support 16 chars): ");
  for (i = 0; i < 120; i++)
    printf("%c", qh->qh_cluster[i]);
  printf("\n");

  printf("Known block size @ creation: %u\n", qh->qh_blksz);
  printf("Ignored: %u\n", qh->qh_kernsz);

  return 0;
}

int
procsss_memb_mask(const char* prefix, memb_mask_t mask)
{
  int x;

  printf("%s: \n", prefix);
  for (x = 0; x < (sizeof(memb_mask_t)); x++)
    {
      int i;
      uint8_t u = mask[x];
      printf("{%d: %02x, ", x, u);
      for (i = 0; i < 8; i++) 
	{
	  printf("[%d]=%d%s", i, (u & 0x1)? 1: 0, i == 7? "": ", ");
	  u >>= 1;
	}
      printf("}, \n");
    }
  printf("\n");
  return 0;
}

int
process_status_block(char *buf, int i)
{
  status_block_t *ps;

  ps = (status_block_t *)(buf + sizeof(shared_header_t));
  swab_status_block_t(ps);
  

  printf("STATUS BLOCK[%d]\n", i);
  printf("Status block magic: 0x%08x\n", ps->ps_magic);
  printf("Last writer: %u\n", ps->ps_updatenode);
  printf("Time of last update: %lu\n", ps->ps_timestamp);
  printf("Nodeid: %u\n", ps->ps_nodeid);
  printf("Padding<0>: %u\n", ps->pad0);
  printf("State: %u(%s)\n", ps->ps_state,
	 (ps->ps_state == S_NONE)?   "S_NONE":
	 (ps->ps_state == S_EVICT)?  "S_EVICT":
	 (ps->ps_state == S_INIT)?   "S_INIT":
	 (ps->ps_state == S_RUN)?    "S_RUN":
	 (ps->ps_state == S_MASTER)? "S_MASTER": 
	                             "UNKOWN");
  printf("Padding<1>: %u\n", ps->pad1[0]);
  printf("Score: %u\n",      ps->ps_score);
  printf("Score max: %u\n",      ps->ps_scoremax);

  printf("Average cycle speed(sec): %u\n",      ps->ps_ca_sec);
  printf("Average cycle speed(usec): %u\n",      ps->ps_ca_usec);

  printf("Last cycle speed(sec): %u\n",      ps->ps_lc_sec);
  printf("Last cycle speed(usec): %u\n",      ps->ps_lc_usec);

  printf("Incarnation: %lu\n",  ps->ps_incarnation);

  printf("Msg: %u(%s)\n", ps->ps_msg,
	 (ps->ps_msg == M_NONE) ? "M_NONE" :
	 (ps->ps_msg == M_BID)  ? "M_BID"  :
	 (ps->ps_msg == M_ACK)  ? "M_ACK"  :
	 (ps->ps_msg == M_NACK) ? "M_NACK" :
	 (ps->ps_msg == M_MASK) ? "M_MASK" : 
	                          "UNKOWN"  );
  printf("Seq: %u\n", ps->ps_seq);
  printf("Arg: %u\n", ps->ps_arg);

  procsss_memb_mask("Mask", ps->ps_mask);
  procsss_memb_mask("Master mask", ps->ps_master_mask);

  return 0;
}

int
process_qdisk(int fd, int blkssz)
{
  int r;
  int blkssz0 = blkssz;
  char* buf = valloc(blkssz);
  int i;

 retry0:  
  r = read(fd, buf, blkssz);
  if (r == 0)
    {
      fprintf(stderr, "Unexpected EOF\n");
      return 3;
    }
  else if (r < 0)
    {
      perror("read");
      return 4;
    }
  else if (r != blkssz)
    {
      buf += r;
      blkssz -= r; 
      
      goto retry0;
    }

  r = process_shared_header(buf, 0);
  if (r != 0)
    goto out;

  r = process_quorum_header(buf);
  if (r != 0)
    goto out;

  
  for (blkssz = blkssz0, i = 0; 
       i < MAX_NODES_DISK; 
       blkssz = blkssz0, i++)
    {
    retry1:  
      r = read(fd, buf, blkssz);
      if (r == 0)
	{
	  fprintf(stderr, "Unexpected EOF\n");
	  return 3;
	}
      else if (r < 0)
	{
	  perror("read");
	  return 4;
	}
      else if (r != blkssz)
	{
	  buf += r;
	  blkssz -= r; 
      
	  goto retry1;
	}
      r = process_shared_header(buf, i + 1);
      if (r != 0)
	goto out;

      r = process_status_block(buf,  i + 1);
      if (r != 0)
	goto out;
    }

 out:
  return r;
}

int
main(int argc, char** argv)
{
  const char* dev;
  int fd;
  int r;


  if (argc == 1 || argc > 2)
    {
      print_usage(argv[0], stderr);
      return 1;
    }
  else if (strcmp(argv[1], "-h") == 0 || strcmp(argv[1], "--help") == 0)
    {
      print_usage(argv[0], stdout);
      return 0;
    }


  dev = argv[1];
  fd  = open(dev, O_RDONLY | O_DIRECT);
  if (fd < 0) 
    {
      perror(dev);
      return 2;
    }

  r = process_qdisk(fd, 4096);
  {
    off_t t;

    t = lseek(fd, 0, SEEK_CUR);
    printf("Total: %lu\n", t);
  }
  
  close(fd);
  return r;
}
