package data;

import haxe.iterators.ArrayIterator;

class OrderedMap<K, V>
{

	private var _keys:Array<K>;
	private var _values:Array<V>;

    public var length(get, never):Int;

	public function new() {
		_keys = [];
		_values = [];
	}

	public function set(key:K, value:V):Void{
		if(_keys.contains(key)){
			var index = _keys.indexOf(key);
			_values[index] = value;
		}
		else{
			_keys.push(key);
			_values.push(value);
		}
	}

    //If the key is already in the map the value is set to the key but it's position remains unchanged and the function returns false;
    public function insert(key:K, value:V, pos:Int):Bool{
		if(_keys.contains(key)){
			var index = _keys.indexOf(key);
			_values[index] = value;
            return false;
		}
		else{
			_keys.insert(pos, key);
			_values.insert(pos, value);
		}
        return true;
	}

	public function get(key:K):Null<V>{
		if(_keys.contains(key)){
			return _values[_keys.indexOf(key)];
		}
		return null;
	}

	public function remove(key:K):Void{
		if(_keys.contains(key)){
			var index = _keys.indexOf(key);
			_keys.remove(key);
			_values.splice(index, 1);
		}
	}
	
	public function exists(key:K):Bool{
		return _keys.contains(key);
	}

	public function iterator():ArrayIterator<V>{
		return new ArrayIterator<V>(_values);
	}

	public function keys():ArrayIterator<K>{
		return new ArrayIterator<K>(_keys);
	}
	
	public function keyValueIterator():OrderedMapKeyValueIterator<K, V>{
		return new OrderedMapKeyValueIterator<K, V>(_keys, _values);
	}

    public function get_length():Int{
        return _keys.length;
    }

}

//Based on ArrayIterator.
class OrderedMapKeyValueIterator<K, V>
{
	final keysArray:Array<K>;
	final valuesArray:Array<V>;
	var current:Int = 0;

	#if !hl inline #end
	public function new(_keysArray:Array<K>, _valuesArray:Array<V>) {
		keysArray = _keysArray;
		valuesArray = _valuesArray;
	}

	#if !hl inline #end
	public function hasNext() {
		return current < keysArray.length;
	}

	#if !hl inline #end
	public function next() {
		final rk = keysArray[current];
		final rv = valuesArray[current];
		current++;
		return {value: rv, key: rk};
	}
}