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

	forskip v 2 [ print rejoin [ v/2 " => " v/1 ] ]
]


restore: funct [ /file version-file ] [

	versions: sort/reverse read %.nit/versions/
	
	a: read/lines versions/1
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


comment {
		versions: sort/reverse read %.nit/versions/
		forall versions [ versions/1: mold versions/1 ] 
}


comment {
ls1: does [ r/text: form read what-dir show r ]
cd1: does [ 
	attempt [ set/any 'e try [ change-dir do a/text ] ] 
	if error? e [ e: disarm e ] 
	r/text: form e
	show r
]

view w: layout compose [ 

	a: field (mold what-dir)
	button "cd" [ cd1 ls1 ]
	button "ls" [ ls1 ]
	r: area 

	button "save" [ save ] 
	button "restore" [ restore ] 
	text-list 
	
	do [ secure none ]

	; a address, r result

	
]




try1: func [ arg ] [
 
	attempt [ set/any 'e try arg ] 
	if error? get/any 'e [ e: disarm e ] 
	if unset? get/any 'e [ e: "" ]

	r/text: form e
	show r
]

tl-update: does [  tl/data: head insert read what-dir %.. tl/sn: 0 tl/sld/data: 0 tl/update show tl ]
view layout compose [ 
	tl: text-list [ if dir? a: to-file value [ try1 [ change-dir a tl-update ] ] ]
	r: field
	do [ try1 [ tl-update ] ]	
]

do-events


}
