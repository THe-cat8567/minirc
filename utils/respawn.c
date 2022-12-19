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
	int es;

	setsid();
	
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
				es = errno;
				perror("Error");
				exit(es);
				break;
			default:
				waitpid(pid, &status, 0);
				// stop respawning only if the file cannot be found
				if(WIFSIGNALED(status))
					continue;
				if (!WIFEXITED(status))
					exit(1);					
				if (WEXITSTATUS(status) == 2)
					exit(status);
				break;
		}
	}
	exit(0);
}
