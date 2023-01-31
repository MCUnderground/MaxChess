callbacks.removeScripts id:#Chess
global C_Objects = #()
global F_Objects
global sF = 100
global ChessI
struct Chess 
(
	currentPlayer = 1,
	White = (
	struct White 
	(
		Pawn = 11,
		Knight = 12,
		Bishop = 13,
		Rook = 14,
		Queen = 15,
		King = 16,
		Pieces = #{11,12,13,14,15,16}
	)
		White()
	),
	Black = (
	struct Black
	(
		Pawn = 21,
		Knight = 22,
		Bishop = 23,
		Rook = 24,
		Queen = 25,
		King = 26,
		Pieces = #{21,22,23,24,25,26}
	)
	Black()
	),
	Board = (
	struct Board
	(
		h = #(14,11,10,10,10,10,21,24),
		g = #(12,11,10,10,10,10,21,22),
		f = #(13,11,10,10,10,10,21,23),
		e = #(16,11,10,10,10,10,21,26),
		d = #(15,11,10,10,10,10,21,25),
		c = #(13,11,10,10,10,10,21,23),
		b = #(12,11,10,10,10,10,21,22),
		a = #(14,11,10,10,10,10,21,24),
		fn GetBoard =
		(
			_Board = #()
			append _Board h 
			append _Board g 
			append _Board f 
			append _Board e
			append _Board d
			append _Board c 
			append _Board b 
			append _Board a 
			return _Board
		)
	)
		Board()
	),
	fn Imager num = 
	(
		_path = pathConfig.removePathLeaf(getThisScriptFilename()) + "\\Pieces\\" + num as string + ".jpg"
	),
	fn CreateBoard = 
	(
		F_Objects = #()
		step = 1
		letters = #("h","g","f","e","d","c","b","a")
		for i = 1 to 8 do (
			for j = 1 to 8 do (
				_Plane = Plane width:sF length:sF pos:[j*sF,i*sF,-0.1]
				_Plane.mat = Standardmaterial()
				if(mod step 2 == 0) then _Plane.mat.diffuse = orange
				else _Plane.mat.diffuse = yellow
				_Plane.Name = letters[i] + j as string
				_Plane.showFrozenInGray = off
				_Plane.lengthsegs = 1
				_Plane.widthsegs = 1
				freeze _Plane
				append C_Objects _Plane
				append F_Objects _Plane
				step = step + 1
			)
			step = step + 1
		)
		_Board = Board.GetBoard()
		for collum = 1 to _Board.count do
		(
			for row = 1 to _Board[collum].count do
			(
				_Plane = Plane()
				_Plane.width = sF-20
				_Plane.length = sF-20
				_Plane.pos = [row*(sF-2),collum*(sF-2),0]
				_Plane.pos.y = _Plane.pos.y + (2 * collum)
				_Plane.pos.x = _Plane.pos.x + (2 * row)
				_Plane.mat = Standardmaterial()
				bmpt = Bitmaptexture()
				bmpt.fileName = Imager _Board[collum][row]
				if _Board[collum][row] < 20 then bmpt.coords.W_Angle = -90
				else bmpt.coords.W_Angle = 90
				if _Board[collum][row] == 10 then _Plane.mat.opacity = 0
				_Plane.mat.diffusemap  = bmpt
				_Plane.mat.showInViewport = true
				_Plane.showFrozenInGray = off
				_Plane.name = _Board[collum][row] as string

				_Plane.lengthsegs = 1
				_Plane.widthsegs = 1
				append C_Objects _Plane
			)
		)
	),
	fn UpdateBoard = 
	(
		ListNames = #("a","b","c","d","e","f","g","h")
		for i = 1 to 8 do
		(
			for j = 1 to 8 do 
			(
				for o in objects do if o.pos.x == (j*sF) and o.pos.y == (i*sF) then 
				(
					Prop = (getProperty Board (ListNames[i]))
					Prop[j] = o.name as integer
				)
			)
		)
		print (Board.GetBoard())
	),
	fn FreezePlayer = 
	(
		ToFreeze = #()
		if currentPlayer == 1 then ToFreeze = (for o in objects where matchpattern o.name pattern:"2*" collect o)
		else ToFreeze = (for o in objects where matchpattern o.name pattern:"1*" collect o)
		for f in ToFreeze do f.showFrozenInGray = off
		freeze ToFreeze
		freeze (for o in objects where matchpattern o.name pattern:"10*" collect o)
	),
	fn UnfreezeBoard = 
	(
		max unfreeze all
	),
	fn GetBoardPlace _piece = 
	(
		collumer = #("a","b","c","d","e","f","g","h")
		for collum = 1 to 8 do 
		(
			_collum = collumer[collum]
			for row = 1 to 8 do
			(
				_node = getNodeByName (_collum+row as string)
				if _piece.pos.x == _node.pos.x then if _piece.pos.y == _node.pos.y do return _node
			)
		)
	),
	fn GetPieceByBoardPlace _place = 
	(
		for piece in Objects do if piece.pos.x == _place.pos.x then if piece.pos.y == _place.pos.y do return piece
	),
	fn IfValidMove str isOp:false = 
	(
		checkState = false
		wp = #("10","11","12","13","14","15","16")
		bp = #("10","21","22","23","24","25","26")
		if isOp then 
		(
			_t = wp
			wp = bp
			bp = _t
		)
		if currentPlayer == 1 do for i in wp do if str == i then if checkState == false do checkState = true
		if currentPlayer == 2 do for i in bp do if str == i then if checkState == false do checkState = true 
		return checkState
	),
	fn GetPieceByCoords piece type  = 
	(
		PieceByCoords = #()
		if type == #Pawn do
		(
			for i = 1 to 2 do 
			(
				_y
				if i == 1 then _y = piece.pos.y - sF
				if i == 2 then _y = piece.pos.y + sF
				for o in Objects do if o.pos.x == piece.pos.x then if _y == o.pos.y then if piece.pos.z == o.pos.z do
				(
					append PieceByCoords o
				)
			)
		)
		return PieceByCoords
	),
	fn MoveRegister Moves = 
	(
		if Moves.count == 0 then ChessI.MainMove()
		DataSet = #()
		for _Move in Moves do
		(
			Data = #()
			append Data _Move
			append Data _Move.mat
			_Move.mat = Standardmaterial()
			_Move.mat.Diffuse = color 0 236 0
			_Move.mat.opacity = 100
			append DataSet Data
			unfreeze _Move
		)
		return DataSet
	),
	fn PieceAttack _piece =
	(
		movePicked = pickObject message:"Select a Move: "
		while movePicked == undefined do movePicked = pickObject message:"Select a Move: "
        if ( isValidNode movePicked ) then 
        (
            if ( movePicked != undefined ) do
            (
            	x = _piece.pos
                _piece.pos = movePicked.pos
                movePicked.pos = x
                UpdateBoard()
                if movePicked.name != "10" then 
                (
                	movePicked.name = "10"
	               	movePicked.mat = Standardmaterial()
	               	movePicked.mat.Diffuse = color 168 168 168
					movePicked.mat.opacity = 0
				)
            )
        )
	),
	fn PawnMove _piece _place = 
	(
		SpawnPlace = if currentPlayer == 1 then "2" else "7"
		PawnMoves = #()
		_PieceAttacks = #()
		allowed_move = 2
		if (_place.name)[2] != SpawnPlace then allowed_move = 1
		for i = 1 to allowed_move do 
		(				
			allowedPlace
			if currentPlayer == 1 then allowedPlace = (_place.name)[1] + (((_place.name)[2] as integer+i) as string)
			else allowedPlace = (_place.name)[1] + (((_place.name)[2] as integer-i) as string)
			_node = getNodeByName allowedPlace
			for o in Objects do if o.pos.x == _node.pos.x then if o.pos.y == _node.pos.y do 
			(
				if ((o.name)[1] == (_place.name)[1]) then continue
				if ((IfValidMove o.name) == false) then
				(
					PiecesByCoords = GetPieceByCoords o #Pawn
					for PieceByCoords in PiecesByCoords do 
					(
						if ((IfValidMove PieceByCoords.name) == false) then append PawnMoves PieceByCoords
					) 
				)
				else 
				(
					PiecesByCoords = GetPieceByCoords o #Pawn
					for PieceByCoords in PiecesByCoords do 
					(
						if ((IfValidMove PieceByCoords.name) == false) then if i == 1 then append PawnMoves PieceByCoords
					)
					if i == 2 and PawnMoves.count == 0 then continue
					append PawnMoves o
				)
			)
		)
		_PieceAttacks = for data in MoveRegister(PawnMoves) collect data
		PieceAttack(_piece)
		for o in _PieceAttacks do if o[1].name == "10" then o[1].mat.opacity = 0 else o[1].mat = o[2]
	),
	fn KnightMove _piece _place = 
	(
		KnightMoves = #()
		offsetArray = #([sF,sF*2],[-sF,sF*2],[sF,-sF*2],[-sF,-sF*2],[sF*2,sF],[sF*2,-sF],[-sF*2,sF],[-sF*2,-sF])
		for i = 1 to 8 do
		(
			for o in objects do 
			(
				if o.pos.x == _piece.pos.x+offsetArray[i].x and o.pos.y == _piece.pos.y+offsetArray[i].y and o.pos.z == _piece.pos.z then
				(
					if o.name == "10" then 
					( 
						append KnightMoves o
						continue
					)
					if IfValidMove(o.name) == false then 
					(
						append KnightMoves o
						exit
					)
					if IfValidMove(o.name) == true do exit
				)
			)
		)
		_PieceAttacks = for data in MoveRegister(KnightMoves) collect data
		PieceAttack(_piece)
		for o in _PieceAttacks do if o[1].name == "10" then o[1].mat.opacity = 0 else o[1].mat = o[2]
	),
	fn BishopMove _piece _place =
	(
		BishopMoves = #()
		offsetArray = #([sF,sF],[-sF,sF],[sF,-sF],[-sF,-sF])
		_offsetArray = #([sF,sF],[-sF,sF],[sF,-sF],[-sF,-sF])
		for i = 1 to offsetArray.count do
		(
			for step = 1 to 8 do (
				abort = false
				for o in objects do 
				(
					if o.pos.x == _piece.pos.x+offsetArray[i].x and o.pos.y == _piece.pos.y+offsetArray[i].y and o.pos.z == _piece.pos.z then
					(
						if o.name == "10" then 
						( 
							append BishopMoves o
							continue
						)
						if IfValidMove(o.name) == true do 
						(
							abort = true
							exit
						)
						if IfValidMove(o.name) == false then 
						(
							append BishopMoves o
							abort = true
							exit
						)
					)
				)
				offsetArray[i] = offsetArray[i] + _offsetArray[i]	
				if abort then exit
			)
		)
		_PieceAttacks = for data in MoveRegister(BishopMoves) collect data
		PieceAttack(_piece)
		for o in _PieceAttacks do if o[1].name == "10" then o[1].mat.opacity = 0 else o[1].mat = o[2]
	),
	fn RookMove _piece _place = 
	(
		RookMoves = #()
		offsetArray = #([sF,0],[-sF,0],[0,sF],[0,-sF])
		_offsetArray = #([sF,0],[-sF,0],[0,sF],[0,-sF])
		for i = 1 to offsetArray.count do
		(
			for step = 1 to 8 do (
				abort = false
				for o in objects do 
				(
					if o.pos.x == _piece.pos.x+offsetArray[i].x and o.pos.y == _piece.pos.y+offsetArray[i].y and o.pos.z == _piece.pos.z then
					(
						if o.name == "10" then 
						( 
							append RookMoves o
							continue
						)
						if IfValidMove(o.name) == true do 
						(
							abort = true
							exit
						)
						if IfValidMove(o.name) == false then 
						(
							append RookMoves o
							abort = true
							exit
						)
					)
				)
				offsetArray[i] = offsetArray[i] + _offsetArray[i]	
				if abort then exit
			)
		)
		_PieceAttacks = for data in MoveRegister(RookMoves) collect data
		PieceAttack(_piece)
		for o in _PieceAttacks do if o[1].name == "10" then o[1].mat.opacity = 0 else o[1].mat = o[2]
	),
	fn QueenMove _piece _place =
	(
		QueenMoves = #()
		offsetArray = #([sF,sF],[-sF,sF],[sF,-sF],[-sF,-sF],[sF,0],[-sF,0],[0,sF],[0,-sF])
		_offsetArray = #([sF,sF],[-sF,sF],[sF,-sF],[-sF,-sF],[sF,0],[-sF,0],[0,sF],[0,-sF])
		for i = 1 to offsetArray.count do
		(
			for step = 1 to 8 do (
				abort = false
				for o in objects do 
				(
					if o.pos.x == _piece.pos.x+offsetArray[i].x and o.pos.y == _piece.pos.y+offsetArray[i].y and o.pos.z == _piece.pos.z then
					(
						if o.name == "10" then 
						( 
							append QueenMoves o
							continue
						)
						if IfValidMove(o.name) == true do 
						(
							abort = true
							exit
						)
						if IfValidMove(o.name) == false then 
						(
							append QueenMoves o
							abort = true
							exit
						)
					)
				)
				offsetArray[i] = offsetArray[i] + _offsetArray[i]	
				if abort then exit
			)
		)
		_PieceAttacks = for data in MoveRegister(QueenMoves) collect data
		PieceAttack(_piece)
		for o in _PieceAttacks do if o[1].name == "10" then o[1].mat.opacity = 0 else o[1].mat = o[2]
	),
	fn KingMove _piece _place =
	(
		KingMoves = #()
		offsetArray = #([sF,0],[-sF,0],[0,sF],[0,-sF],[sF,sF],[-sF,sF],[-sF,-sF],[sF,-sF])
		for i = 1 to 8 do
		(
			for o in objects do 
			(
				if o.pos.x == _piece.pos.x+offsetArray[i].x and o.pos.y == _piece.pos.y+offsetArray[i].y and o.pos.z == _piece.pos.z then
				(
					if o.name == "10" then 
					( 
						append KingMoves o
						continue
					)
					if IfValidMove(o.name) == false then 
					(
						append KingMoves o
						exit
					)
					if IfValidMove(o.name) == true do exit
				)
			)
		)
		_PieceAttacks = for data in MoveRegister(KingMoves) collect data
		PieceAttack(_piece)
		for o in _PieceAttacks do if o[1].name == "10" then o[1].mat.opacity = 0 else o[1].mat = o[2]
	),
	fn PieceMove _piece _place = 
	(
		Frozen =  for o in C_Objects where o.isFrozen collect o
		Unfrozen = for o in C_Objects where o.isFrozen == false collect o
		freeze Unfrozen
		if _piece.name == "11" or _piece.name == "21" then PawnMove _piece _place 
		if _piece.name == "12" or _piece.name == "22" then KnightMove _piece _place
		if _piece.name == "13" or _piece.name == "23" then BishopMove _piece _place
		if _piece.name == "14" or _piece.name == "24" then RookMove _piece _place 
		if _piece.name == "15" or _piece.name == "25" then QueenMove _piece _place 
		if _piece.name == "16" or _piece.name == "26" then KingMove _piece _place 
		if currentPlayer == 1 then currentPlayer = 2 else currentPlayer = 1
		unfreeze Unfrozen
	),
	fn MainMove = 
	(
		UnfreezeBoard()
		FreezePlayer()
		Freeze F_Objects
		movePicked = pickObject message:"Select a Move: "
		while movePicked == undefined do movePicked = pickObject message:"Select a Move: "
		BoardPlace = GetBoardPlace movePicked
		PieceMove movePicked BoardPlace
		MainMove()
	)
)
ChessI = Chess()
max unfreeze all
max select all
delete selection
ChessI.CreateBoard()
ChessI.MainMove()