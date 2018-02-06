import java.util.ArrayList;
import java.util.HashSet;

public class ClassA {

	// Duplication
	int h = -1;
	int i = 0;
	int j = 1;
	int k = 2;
	int l = 3;
	int m = 4;
	
	public int getHNotDuplicatedTooSmall() {
		return h;
	}
	
	public int getHAndJDuplicated6Lines() {
		// line comment 1
		int temp = h + i;
		int c = 0;
		// line comment 2
		int d = 0;
		int e = 0;
		return temp;
	}
	
	public void veryComplexAndDuplicated() {
		if (h == 1) {
			if (i == 0) {
				if (m == 4) {
					ArrayList l = new ArrayList();
					HashSet s = new HashSet();
					System.out.println("hello");
				}
			}
		}
	}
	
	public void testMethod1() {
		assert(1 == 1);
	}

	public void testMethod2() {
		assert(1 == 1);
	}

	public void testMethod3() {
		assert(1 == 1);
	}

}
