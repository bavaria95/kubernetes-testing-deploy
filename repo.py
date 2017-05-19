import git
import argparse

parser = argparse.ArgumentParser(description="Downloads repository and resets to a certain commit")
parser.add_argument("--repository", help="URI of git repository",
                    default="https://github.com/inspirehep/inspire-next.git")
parser.add_argument("commit", help="commit hash")
args = parser.parse_args()

if __name__ == '__main__':
    r = git.Repo.clone_from(args.repository, '%s' % args.commit).git.reset(args.commit)
