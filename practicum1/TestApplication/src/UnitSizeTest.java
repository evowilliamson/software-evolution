
public class UnitSizeTest {
	public int method_LOC4(){
		System.out.println("test");
		
		return 4;	
	}
	
	/**
	 * Do something with comment, ignore empty lines and comment line 
	 */
	public int method_WithComments_LOC4(){
		System.out.println("test");
		
		//Return
		return 4;	
	}
	
	/**
	 * Do something with comment, ignore empty lines and comment line 
	 */
	public int method_WithComments_LOC5(){
		System.out.println("test"); //test
		
		int x = 5;
		if (x > 5) {
			System.out.println("> 5"); 
		}
		
		//Return
		return 5;	
	}
}
