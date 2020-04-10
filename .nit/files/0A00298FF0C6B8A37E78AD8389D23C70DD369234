rebol []

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


revert-to: funct [ file ] [
	a: read/lines file	
	forskip a 2 [ print rejoin [ a/1 " => " a/2 ] attempt [ write to-file a/2 read to-file a/1 ] ]
]


try1: func [ arg ] [
	attempt [ set/any 'e try arg ] 
	if error? get/any 'e [ e: disarm e ] 
	if unset? get/any 'e [ e: "" ]
    print e
]


insert-all: func [ a b ] [
    forall a [ a/1: head insert a/1 b ]
    a: head a
    return a
]


gui-update: has [ dir ] [  

    f/data: append copy [ %.. ] read what-dir
    s/data: sort/reverse read dir: %.nit/states/
    insert-all s/data dir

    f/sn: 0 
    f/sld/data: 0 
    f/update 
    show f 

    show s 

]

gui-change-dir: func [ value ] [
    if dir? a: to-file value [ try1 [ change-dir a gui-update ] ]
]

view layout compose [ 
	f: text-list 450x450 [ gui-change-dir value ]
    s: text-list  450x300
    across
	button "revert" [ revert-to first s/picked   s/picked: append reduce [ s/data/1 ] gui-update ] 
	button "commit" [ commit gui-update ]

	do [ gui-update ]	
]