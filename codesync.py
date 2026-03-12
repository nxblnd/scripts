#!/usr/bin/env python3

import shutil
import sys
import json
from pathlib import Path
from enum import Enum
import logging
from typing import Optional
import subprocess

log: logging.Logger = logging.getLogger(__name__)

class ConfigException(Exception):
    pass

class AnsiColors(str, Enum):
    RED = '\033[31m'
    YELLOW = '\033[33m'
    CYAN = '\033[36m'
    RESET = '\033[0m'

class LogLevelColors(Enum):
    CRITICAL = AnsiColors.RED.value
    ERROR = AnsiColors.RED.value
    WARNING = AnsiColors.YELLOW.value
    INFO = AnsiColors.CYAN.value
    DEBUG = AnsiColors.RESET.value

class ColorFormatter(logging.Formatter):
    def format(self, record):
        record.levelname = f'{LogLevelColors[record.levelname].value}{record.levelname}{AnsiColors.RESET.value}'
        return super().format(record)

class GitMode(str, Enum):
    FETCH = 'fetch'
    PUSH = 'push'

class Repository:
    path: Path
    url: Optional[str]
    remote: Optional[str]
    branch: Optional[str]
    mode: GitMode
    args: Optional[list[str]]

    def __init__(self,
                 path: str | Path,
                 url: Optional[str] = None,
                 remote: Optional[str] = None,
                 branch: Optional[str] = None,
                 mode: GitMode = GitMode.FETCH,
                 args: Optional[list[str]] = None) -> None:

        self.path = Path(path).expanduser()

        self.args = []
        if args is not None:
            for arg in args:
                if '=' in arg:
                    key, value = arg.split("=", 1)
                    expanded_path_value = str(Path(value).expanduser())
                    self.args.append(f'{key}={expanded_path_value}')
                    log.debug(f'Expanded path argument "{value}" into "{expanded_path_value}"')
                else:
                    self.args.append(arg)

        self.branch = self.config(['init.defaultBranch']).strip() if branch is None else branch
        self.remote = self.config([f'branch.{self.branch}.remote']).strip() if remote is None else remote
        self.url = self.config([f'remote.{self.remote}.url']).strip() if url is None else url
        self.mode = mode

    def __repr__(self):
        return ''.join(['Repository(',
                        f'path="{self.path}", ',
                        f'url="{self.url}", ',
                        f'remote="{self.remote}", ',
                        f'branch="{self.branch}", ',
                        f'mode={self.mode}, ',
                        f'args={self.args}',
                        ')'])

    @classmethod
    def from_dict(cls, data: dict) -> "Repository":
        if 'path' not in data:
            raise ConfigException('No path found')

        return cls(
            path = data.get('path'),
            url = data.get('url'),
            remote = data.get('remote'),
            branch = data.get('branch'),
            mode = GitMode(data.get('mode', GitMode.FETCH)),
            args = data.get('args')
        )

    def command(self,
                cmd: str,
                cmd_args: Optional[list[str]] = None) -> subprocess.CompletedProcess:
        if cmd_args is None:
            cmd_args = []
        full_cmd = ['git', *self.args, cmd, *cmd_args]

        result = subprocess.run(
            full_cmd,
            cwd=self.path,
            capture_output=True,
            text=True,
        )
        log.debug(result)

        return result

    def fetch(self) -> None:
        self.command('fetch', [self.remote, self.branch])

    def push(self) -> None:
        self.command('push', [self.remote, self.branch])

    def is_inside_work_tree(self) -> bool:
        return self.command('rev-parse').returncode == 0

    def config(self, cmd_args: Optional[list[str]] = None) -> str:
        return self.command('config', cmd_args).stdout


def check_git_executable() -> None:
    if not shutil.which('git'):
        sys.exit('Git not found')

def read_config(path: Path) -> list[Repository]:
    log.debug(f'Reading config file "{path}"')
    with open(path) as file:
        config = json.load(file)
        if not isinstance(config, list):
            raise ConfigException('Wrong config format')
        return [Repository.from_dict(entry) for entry in config]

def process_repo(repo: Repository):
    log.info(repo)

    if not repo.is_inside_work_tree():
        raise Exception(f'{repo.path} is not a git repo')

    if repo.mode == GitMode.FETCH:
        repo.fetch()
    if repo.mode == GitMode.PUSH:
        repo.fetch()
        repo.push()

def setup_logs(level: logging._Level = logging.WARNING):
    log.setLevel(level)

    formatter = ColorFormatter('[%(levelname)s]\t%(message)s')
    handler = logging.StreamHandler()
    handler.setFormatter(formatter)
    log.addHandler(handler)

def main():
    setup_logs(logging.DEBUG)

    check_git_executable()

    config_dir = Path.home() / '.config' / 'codesync'
    log.debug(f'Config dir "{config_dir}"')

    for config_path in config_dir.glob('**/*.json'):
        try:
            config = read_config(config_path)

            for repo in config:
                process_repo(repo)
        except ConfigException as error:
            log.error(f'{error} (config file "{config_path}")')
            continue
        except Exception as error:
            log.error(f'{error}')
            continue


if __name__ == '__main__':
    main()
