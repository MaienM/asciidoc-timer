BEGIN {
	COMMAND = "date +'%s%N'"

	level = 0
	nextsectionnumber = 0
	maxtitlelength = 0

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

		# Store the max title size
		calculateprefix(newlevel)
		titlelength = length(newtitle) + prefixlength
		if (titlelength > maxtitlelength) {
			maxtitlelength = titlelength
		}
	}

	print $0
}

function calculateprefix(lvl) {
	prefix = ""
	prefixucount = 0

	# Prefix with one ideagraphic space (U+3000) per level
	for (l = 2; l < lvl; l++) {
		prefix = prefix "　"
		prefixucount++
	}

	# Add the sub-item-of character, which is actually 2 unicode characters
	if (lvl > 1) {
		prefix = prefix "└─ "
		prefixucount = prefixucount + 2
	}

	prefixlength = length(prefix) - 2 * prefixucount
}

END {
	close_sections(1)
	print ""
	print ""
	print "== Timings"
	print ""
	print "[options='header', cols='8,1', frame='none', stripe='odd']"
	print "|====="
	printf("| %-" maxtitlelength "s | %s\n", "Section", "Duration")
	for (i = 0; i < nextsectionnumber; i++) {
		lvl = results[i "level"]
		calculateprefix(lvl)
		width = maxtitlelength + prefixlength + 1
		if (prefixucount <= 0) {
			width--
		}
		printf(\
			"| %-" width "s | %0.1fs\n",\
			prefix results[i "title"],\
			results[i "duration"]\
		)
	}
	print "|====="
}
