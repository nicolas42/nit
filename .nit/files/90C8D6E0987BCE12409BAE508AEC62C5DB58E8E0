rebol []

comment {

Branching could be implemented with directories inside the state folder

states
+gui
 +v1
 +v2
+cli
 +v1
 +v2

active-branch: ""
branch: func [ arg ] [
	make-dir %.nit/(arg)
	active-branch: arg
]

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
	rejoin [ "" zero-extend now/year 4 zero-extend now/month 2 
		zero-extend now/day 2 "-" now-time ]
]

init: funct [ ] [

	attempt probe [
	make-dir %.nit/
	make-dir %.nit/files/
	make-dir %.nit/states/
	]

]

commit: funct [ ] [

	v: copy [ ] 
	file-walk %. func [ f ] [ 
	
		if find/match f "./.nit" [ return ]
		
		filename: join %./.nit/files/ mold checksum/method f 'sha1
		foreach c "#{}" [ replace/all filename c "" ]
		write filename read f
		append v filename  append v f   
	]   
	write/lines rejoin [ %.nit/states/ now-descending ] v

	forskip v 2 [ print rejoin [ v/2 " => " v/1 ] ]
]

revert: funct [ n ] [

	states: sort/reverse read dir: %.nit/states/
	a: read/lines join dir states/(n)
	
; 	no delete for the time being	
;	foreach f read %. [ if not find/match f ".nit" [ either dir? f [ delete-dir f ] [ delete f ] ] ]
	
	forskip a 2 [ print rejoin [ a/1 " => " a/2 ] attempt [ write to-file a/2 read to-file a/1 ] ]
]

commit-to: funct [ file ] [

	v: copy [ ] 
	file-walk %. func [ f ] [ 
	
		if find/match f "./.nit" [ return ]
		
		filename: join %./.nit/files/ mold checksum/method f 'sha1
		foreach c "#{}" [ replace/all filename c "" ]
		write filename read f
		append v filename  append v f   
	]   

	write/lines rejoin [ %.nit/states/ arg ] v

	forskip v 2 [ print rejoin [ v/2 " => " v/1 ] ]
]

revert-to: funct [ file ] [
	a: read/lines file	
	forskip a 2 [ print rejoin [ a/1 " => " a/2 ] attempt [ write to-file a/2 read to-file a/1 ] ]
]

halt
