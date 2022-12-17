#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/ioctl.h>

int fd;

int main(int ac, char *av[])
{
	// Show usage
	if(ac < 5) {
		fprintf(stderr, "usage: %s PID motoraddress iocmd value [count]\n", av[0]);
		exit(1);
	}

	// Set memory path
	char mem_path[64];
	snprintf(mem_path, sizeof(mem_path), "/proc/%s/mem", av[1]);

	// Open memory of process
	if((fd = open(mem_path, O_RDONLY)) < 0) {
		fprintf(stderr, "Can't access %s\n", av[1]);
		perror(":");
		exit(1);
	}

	// Get params
	ulong mtrfdaddr = strtoul(av[2], 0, 16);
	ulong iocmd = strtoul(av[3], 0, 16);
	ulong value = strtoul(av[4], 0, 16);
	ulong count = 1;
	if(ac >= 6)
		count = strtoul(av[5], 0, 10);

	// Read motor file descriptor value
	lseek(fd, mtrfdaddr, SEEK_SET);
	ulong mtrfd = 0;
	read(fd, &mtrfd, 4);

	// Feedback
	fprintf(stderr, "mtrfdaddr=%x mtrfd=%x val=%x\n", mtrfdaddr, mtrfd, value);

	// Send command if we have a valid descriptor
	if(mtrfd!=0) {
		char fd_path[64];
		snprintf(fd_path, sizeof(fd_path), "/proc/%s/fd/%d", av[1], mtrfd);
		int new_fd = open(fd_path, O_RDWR);
		fprintf(stderr, "fd_path=%s new_fd=%d\n", fd_path, new_fd);
		int ret = 0;
		while(count-- > 0) {
			ret = ioctl(new_fd, iocmd, (int32_t*) &value);
			usleep(10000);
			fprintf(stderr, "count=%d\n", count);
		}
		fprintf(stderr, "ret=%x\n", ret);
		close(new_fd);
	}
	exit(0);
}
