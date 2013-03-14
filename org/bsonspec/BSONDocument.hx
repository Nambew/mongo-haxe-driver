package org.bsonspec;

/**
 * This class use String for key and Dynamic for storing
 * the value part. The $ is permit for encoding mongoDB query.
 * 
 * Example
 * 
 * var doc:BSONDocument = BSONDocument.create()
 *			.append( "_id", new ObjectID() )
 *			.append( "title", 'My awesome post' )
 *			.append( "hol", ['first', 2, Date.now()] )
 *			.append( "options", BSONDocument.create()
 *				.append( "delay", 1.565 )
 *				.append( "test", true )
 *				)
 *			.append( "monkey", null )
 *			.append( "$in", [1,3] );
 * 
 * BSON.encode( doc );
 * 
 * @author Andre Lacasse
 */
class BSONDocument
{
	private static var SEPARATOR:String = "/";
	
	private var _nodes:List<BSONDocumentNode>;
	private var _keys:Hash<BSONDocumentNode>;
	
	public function new() 
	{
		_nodes = new List<BSONDocumentNode>();
		_keys = new Hash<BSONDocumentNode>();
	}
	
	public static function create():BSONDocument
	{
		return new BSONDocument();
	}
	
	public function append(key:String, value:Dynamic):BSONDocument 
	{
		var node:BSONDocumentNode = new BSONDocumentNode( key, value );
		_nodes.add( node ); 
		_keys.set( key, node );
		return this;
	}
	
	public function nodes():Iterator<BSONDocumentNode>
	{
		return _nodes.iterator();
	}
	
	public function exists( key:String ):Bool 
	{
		var keyParts:Array<String> = parseKey( key );
		
		if ( validFirstKeyPart( keyParts ) ) {
			
			if ( keyParts.length == 1 ) {
				return true;
			} else {
				var firstPart:String = keyParts.shift();
				var node:BSONDocumentNode = _keys.get( firstPart );
				
				if ( node.isDocument() ) {
					var doc:BSONDocument = cast( node.data, BSONDocument );
					return doc.exists( keyParts.join( SEPARATOR ) );
				} else {
					return false;
				}
			}
			
		} else {
			return false;
		}
		
		
	}
	
	public function get( key:String ):Dynamic 
	{
		var keyParts:Array<String> = parseKey( key );

		if ( validFirstKeyPart( keyParts ) ) {
			
			var node:BSONDocumentNode = _keys.get( keyParts[ 0 ] );
			
			if ( keyParts.length == 1 ) {
				return node.data;
			} else {
				var firstPart:String = keyParts.shift();

				if ( node.isDocument() ) {
					var doc:BSONDocument = cast( node.data, BSONDocument );
					return doc.get( keyParts.join( SEPARATOR ) );
				} else {
					throw "Invalid key chain.";
				}
			}
			
		} else {
			throw "Invalid key chain.";
		}
	}
	
	private function validFirstKeyPart( keyParts:Array<String> ):Bool 
	{
		return ( keyParts.length > 0 && _keys.exists( keyParts[ 0 ] ) );
	}
	
	private inline function parseKey( key:String ):Array<String>
	{
		return key.split( SEPARATOR );
	}
	
	public function toString():String
	{
		var iterator:Iterator<BSONDocumentNode> = _nodes.iterator();
		var s:StringBuf = new StringBuf();
		s.add( "{" );

		for ( node in iterator )
		{
			s.add( " " + node.key + " : " + node.data );
			
			if ( iterator.hasNext() ) s.add( "," );
		}
		
		s.add( "}" );
		
		return s.toString();
	}
	
}
