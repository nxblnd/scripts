#!/usr/bin/env sh

# Print number of commits in each month

number_of_commits="$(git rev-list HEAD | \
    git show --stdin --no-patch --format='%cd' --date='format:%Y-%m' | \
    sort | uniq -c)"

if command -v "python3" > /dev/null 2>&1
then
    echo "$number_of_commits" | python -c '
import sys
import datetime as dt
import math

def month_range(start: dt.date, end: dt.date = dt.date.today()) -> Generator[str]:
    current_year, current_month = start.year, start.month
    while current_year <= end.year:
        while current_month < 13:
            if current_year == end.year and current_month > end.month:
                return
            yield f"{current_year}-{current_month:02d}"
            current_month += 1
        current_year += 1
        current_month = 1


raw_data = sys.stdin.read().strip().split("\n")

if not raw_data:
    sys.exit()

data = {date: int(count) for count, date in (entry.strip().split() for entry in raw_data)}

max_count = max(data.values())
padding = len(str(max_count))
bar_chr = "#"
first_year, first_month = raw_data[0].strip().split()[1].split("-")
start_date = dt.date(int(first_year), int(first_month), 1)

for month_str in month_range(start_date):
    commit_count = data.get(month_str, 0)
    print(f"{month_str}  {commit_count:>{padding}}  [{bar_chr * math.floor(commit_count / max_count * 20):<20}]")
'
else
    echo "$number_of_commits"
fi

