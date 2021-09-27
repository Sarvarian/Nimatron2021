class_name Nim
extends Object


static func play(
	heaps : PoolByteArray,
	rng : RandomNumberGenerator,
	misere : bool = false
	) -> PoolByteArray:
	
	if not heaps or is_heaps_empty(heaps):
		return PoolByteArray([0, 0])
	
	var is_endgame : bool = false
	if count_non_0_1(heaps) <= 1:
		is_endgame = true
	
	if misere and is_endgame:
		
		var is_odd : bool = false
		if (moves_left(heaps) % 2) == 1:
			is_odd = true
		
		var index_of_max : int = begest_heap(heaps)
		var sizeof_max : int = heaps[index_of_max]
		
		#if sizeof_max == 1 and is_odd:
		#	return "You will lose :("
		#	pass
		
		return PoolByteArray([index_of_max, sizeof_max - int(is_odd)])
	
	var nim_sum : int = nim_sum(heaps)
	
	if nim_sum == 0:
		var res : int
		while true:
			res = rng.randi_range(0, heaps.size() - 1)
			if heaps[res] > 0:
				return PoolByteArray([res, 1])
#		return "You will lose :("
	
	for i in heaps.size():
		var target_size : int = heaps[i] ^ nim_sum
		if target_size < heaps[i]:
			var amount_to_remove : int = heaps[i] - target_size
			return PoolByteArray([i, amount_to_remove])
	
	for i in heaps.size():
		if heaps[i] > 0:
			return PoolByteArray([i, 1])
	
	
	return PoolByteArray([0, 0])


static func count_non_0_1(
	heaps : PoolByteArray
	) -> int:
	
	var counter : int = 0
	
	for x in heaps:
		if x > 1:
			counter += 1
	
	return counter


static func moves_left(
	heaps : PoolByteArray
	) -> int:
	
	var counter : int = 0
	
	for x in heaps:
		if x > 0:
			counter += 1
	
	return counter


static func begest_heap(
	heaps : PoolByteArray
	) -> int:
	
	var index : int = 0
	
	for i in heaps.size():
		if heaps[i] > heaps[index]:
			index = i
	
	return index


static func nim_sum(
	heaps : PoolByteArray
	) -> int:
	
	var sum : int = 0
	
	for x in heaps:
		sum ^= x
	
	return sum


static func is_heaps_empty(heaps : PoolByteArray) -> bool:
	for h in heaps:
		if h > 0:
			return false
	return true


#static func produse_random_move(
#	heaps : PoolByteArray,
#	rng : RandomNumberGenerator
#	) -> PoolByteArray:
#
#	var move : PoolByteArray = [0, 0]
#
#	var count : int = 0
#	for h in heaps:
#		count += h
#
#	var rand_num : int = rng.randi_range(0, count)
#
#	return move

