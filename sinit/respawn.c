#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <sys/wait.h>
#include <errno.h>

int main(int argc, char* argv[])
{
	if (argc < 2)
	{
		printf("respawn: cmd [args]\n");
		exit(1);
	}
	
	pid_t pid;
	int status;
	while (1)
	{
		pid = fork();
		switch (pid)
		{
			case -1:
				perror("Error");
				exit(1);
			case 0:
				execvp(argv[1], argv+1);
				perror("Error");
				exit(1);
				break;
			default:
				waitpid(pid, &status, 0);
				// do not respawn failing children
				if (!WIFEXITED(status))
					exit(1);
				if (WEXITSTATUS(status) != 0)
					exit(status);
				break;
		}
	}
	exit(0);
}
