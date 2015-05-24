echo "==> Setting up git hooks for the project..."
PROJECT_HOME=`git rev-parse --show-toplevel`
ln -s -f $PROJECT_HOME/hooks/pre-commit $PROJECT_HOME/.git/hooks/pre-commit
