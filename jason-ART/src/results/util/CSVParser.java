package results.util;

import java.util.ArrayList;
import java.util.List;
import java.util.StringTokenizer;

public class CSVParser {

    public static List<String> parse(String line) {
        List<String> result = new ArrayList<String>();
        StringTokenizer in = new StringTokenizer(line,",");
        while (in.hasMoreTokens()) {
            result.add(in.nextToken());
        }
        return result;
    }

}
