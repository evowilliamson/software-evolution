import java.io.File;

public class CyclomaticComplexityTest {
	/**
	 * Test , cc = 1
	 */
	public int Method_1() {
		int x = 2;
		System.out.println("d");
		
		return 1;
	}
	
	/**
	 * Test if, cc = 2
	 */
	public int Method_If_2() {
		int x = 2;
		if (x >6)
		{
			System.out.println("d");
		}		
		
		return 2;
	}
	
	/**
	 * test if with and, cc = 3
	 */
	public int Method_IfWithAnd_3() {
		int x = 2;
		if (x >6 && x < 10)
		{
			System.out.println("d");
		}		
		
		return 3;
	}
	
	/**
	 * test if with or, cc = 3
	 */
	public int Method_IfWithOr_3() {
		int x = 2;
		if (x >6 || x > 10)
		{
			System.out.println("d");
		}		
		
		return 3;
	}	

	/**
	 * test if with two and's, cc = 4
	 */
	public int Method_IfWithTwoAnds_4() {
		int x = 2;
		if (x == 6 && x > 10 && x != 89)
		{
			System.out.println("d");
		}		
		
		return 4;
	}	
	
	/**
	 * test if with foreach, cc = 2
	 */
	public int Method_Foreach_2() {
		int arr[]={12,13,14,44};  
		  
		   for(int i:arr){  
		     System.out.println(i);  
		   }  
		
		return 2;
	}	
	
	/**
	 * test if with for, cc = 2
	 */
	public int Method_For_2() {
		int arr[]={12,13,14,44};  
		  
		   for(int i = 0; i < arr.length; i++){  
		     System.out.println(arr[i]);  
		   }  
		
		return 2;
	}	
	
	/**
	 * test if with do, cc = 2
	 */
	public int Method_do_2() {
		int i = 24;	
		  
		do {
			i--;
		}while(i > 0);
		
		return 2;
	}	
	
	/**
	 * test if with whil, cc = 2
	 */
	public int Method_while_2() {
		int i = 24;	
		  
		while(i > 0) {
			i--;
		}
		return 2;
	}	
	
	/**
	 * Test catch, cc = 2
	 */
	public int Method_Catch_2() {
		
		try {
			System.out.println("x");
		}
		catch(Exception ex) {
			System.out.println("catch");
		};
		
		return 2;
	}
	
	/**
	 * Test two catches, cc = 3
	 */
	public int Method_TwoCatches_3() {
		
		try {
			System.out.println("x");
			
			File f = new File("");
		}
		catch(NullPointerException ex) {
			System.out.println("catch 1");
		}
		catch(Exception ex) {
			System.out.println("catch 2");
		};
		
		return 2;
	}
	
	/**
	 * Test switch with four cases, cc = 5
	 */
	public int Method_SwithcWithFourCases_5(int i) {
		switch(i) {
			case 1:System.out.println("1");break;
			case 2:System.out.println("2");break;
			case 3:System.out.println("3");break;
			case 4:System.out.println("4");break;
		}
		
		return 5;
	}
}
