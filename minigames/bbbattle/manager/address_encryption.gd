class_name Encryption
extends Node


static func encrypt_address(address):
	var address_array = address.split(".")
	
	var encrypted_address_array:Array = []
	
	for i in range(address_array.size()):
		var number = int(address_array[i])
		number += 1
		number *= 3
		number -= 12
		encrypted_address_array.append(str(number))
	
	
	var encrypted_address:String = ".".join(encrypted_address_array)
	return encrypted_address
static func decrypt_address(address):
	var address_array = address.split(".")
	var encrypted_address_array:Array = []
	
	for i in range(address_array.size()):
		var number = int(address_array[i])
		number += 12
		number /= 3
		number -= 1
		encrypted_address_array.append(str(number))
	
	
	var encrypted_address:String = ".".join(encrypted_address_array)
	return encrypted_address
