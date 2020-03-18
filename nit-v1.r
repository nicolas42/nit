rebol []

comment { 
	In the future perhaps now-descending should use the gmt time for a team who 
	might move around.
		now-time: replace/all mold now/time - now/zone ":" ""
	
	Improvements
	push to s3
	gitignore's purpose is to prevent the size of the package from becoming too large and unweildly
	perhaps a flag indicating that there's a file which is above a certain size or of a particular type would be a good idea?

}


file-walk: func [
	{Deep read a directory given a dir d
	an output block o and a boolean function fn}
	d fn /local f
] [
	f: read d
	foreach f f [ do :fn d/:f ]
	foreach f f [ if #"/" = last f [ file-walk d/:f :fn ] ]
]

zero-extend: funct [ a n ] [ a: mold a  head insert/dup a "0" n - length? a ]

now-descending: funct [ ] [
	now-time: replace/all mold now/time ":" ""
	rejoin [ "" zero-extend now/year 4 zero-extend now/month 2 zero-extend now/day 2 "-" now-time ]
]

init: funct [ ] [

	attempt probe [
	make-dir %.nit/
	make-dir %.nit/files/
	make-dir %.nit/versions/
	]

]

save: funct [ ] [

	v: copy [ ] 
	file-walk %. func [ f ] [ 
	
		if find/match f "./.nit" [ return ]
		
		filename: join %./.nit/files/ mold checksum/method f 'sha1
		foreach c "#{}" [ replace/all filename c "" ]
		write filename read f
		append v filename  append v f   
	]   
	write/lines rejoin [ %.nit/versions/ now-descending ] v
	write/lines %.nit/versions/current v

	forskip v 2 [ print rejoin [ v/2 " => " v/1 ] ]
]


restore: funct [ /file version-file ] [

	a: read/lines %.nit/versions/current
	if file [ a: read/lines version-file ]

	foreach f read %. [ if not find/match f ".nit" [ either dir? f [ delete-dir f ] [ delete f ] ] ]
	
	forskip a 2 [ print rejoin [ a/1 " => " a/2 ] attempt [ write to-file a/2 read to-file a/1 ] ]
]

change-dir %..

print {

=== NIT VERSION CONTROL SYSTEM ===
because I can't remember how git revert works

There's two functions - commit and revert.

Save saves a version

	save

Restore restores the most recent version  

	restore

or a particular one

	restore/to <file> 


The versions are stored in .nit/versions<date-time>
The files are stored in .nit/files/<sha1-hash> 

We will control versions and do the other things.  
Not because it is easy but because it is hard.

}

halt
