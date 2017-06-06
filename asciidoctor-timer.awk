BEGIN {
	COMMAND = "date +'%s%N'"

	level = 0
	nextsectionnumber = 0

	strftime = PROCINFO["strftime"]
}

function close_sections(tolevel) {
	for (l = level; l >= tolevel; l--) {
		results[sectionnumbers[l] "level"] = l
		results[sectionnumbers[l] "title"] = titles[l]
		results[sectionnumbers[l] "duration"] = (time - timers[l]) / 1000 / 1000 / 1000
		timers[l] = 0
		titles[l] = ""
		sectionnumbers[l] = 0
	}
}

{
	COMMAND | getline time
	close(COMMAND)

	newlevel = 0
	if (/^= /) { newlevel = 1 }
	if (/^== /) { newlevel = 2 }
	if (/^=== /) { newlevel = 3 }
	if (/^==== /) { newlevel = 4 }
	if (/^===== /) { newlevel = 5 }
	if (/^====== /) { newlevel = 6 }
	newtitle = substr($0, newlevel + 2)

	if (newlevel > 0) {
		# Close off old sections
		close_sections(newlevel)

		# Store the new section
		level = newlevel
		timers[newlevel] = time
		titles[newlevel] = newtitle
		sectionnumbers[newlevel] = nextsectionnumber++
	}

	print $0
}

END {
	close_sections(1)
	print ""
	print ""
	print "== Timings"
	print ""
	print "|====="
	print "| Section                    | Duration"
	for (i = 0; i < nextsectionnumber; i++) {
		lvl = results[i "level"]
		prefix = substr("      ", 0, lvl - 1)
		width = 30
		if (lvl > 1) {
			prefix = prefix "└─ "
		} else {
			width = width - 4
		}
		printf(\
			"| %-" width "s | %0.1fs\n",\
			prefix results[i "title"],\
			results[i "duration"]\
		)
	}
	print "|====="
}
