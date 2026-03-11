#!/usr/bin/env python3

import shutil
import sys
import json
from pathlib import Path
from dataclasses import dataclass, field
from enum import Enum
import logging as log
from typing import Optional
import subprocess

class GitMode(str, Enum):
    FETCH = 'fetch'
    PUSH = 'push'

@dataclass
class Repository:
    path: Path
    url: Optional[str] = None
    remote: Optional[str] = None
    branch: Optional[str] = None
    mode: GitMode = GitMode.FETCH
    args: list[str] = field(default_factory=list)

    def __post_init__(self):
        self.path = self.path.expanduser()

        if self.url is None or self.url == '':
            pass

        if self.remote is None:
            pass

        if self.branch is None:
            pass

    @classmethod
    def from_dict(cls, data: dict) -> "Repository":
        if 'path' not in data:
            raise KeyError('No path found')

        return cls(
            path = Path(data.get('path')),
            url = data.get('url'),
            remote = data.get('remote'),
            branch = data.get('branch'),
            mode = GitMode(data.get('mode', GitMode.FETCH)),
            args = data.get('args')
        )


def check_git_executable() -> None:
    if not shutil.which('git'):
        sys.exit('Git not found')

def read_config(path: Path) -> list[Repository]:
    with open(path) as file:
        config = json.load(file)
        if not isinstance(config, list):
            raise ValueError('Wrong config format')
        return [Repository.from_dict(entry) for entry in config]

def process_repo(repo):
    pass

def main():
    check_git_executable()

    config_dir = Path.home() / '.config' / 'codesync'
    for config_path in config_dir.glob('**/*.json'):
        try:
            config = read_config(config_path)
        except Exception as e:
            log.error(e)
            continue
        import pprint
        pprint.pprint(config)
        for repo in config:
            process_repo(repo)


if __name__ == '__main__':
    main()
