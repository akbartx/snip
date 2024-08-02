class CodeExamples {
  static final List<String> languages = [
    'bash', 'c', 'cpp', 'css', 'dart', 'go', 'html', 'java', 'javascript',
    'json', 'kotlin', 'markdown', 'objectivec', 'php', 'python', 'ruby',
    'rust', 'swift', 'typescript', 'xml', 'yaml'
  ];

  static final Map<String, String> examples = {
    'dart': '''
void main() {
  print('Hello, World!');
}
''',
    'python': '''
def greet():
    print("Hello, World!")

greet()
''',
    'javascript': '''
function greet() {
    console.log("Hello, World!");
}

greet();
''',
    'java': '''
public class Main {
    public static void main(String[] args) {
        System.out.println("Hello, World!");
    }
}
''',
    'c': '''
#include <stdio.h>

int main() {
    printf("Hello, World!\\n");
    return 0;
}
''',
    'cpp': '''
#include <iostream>

int main() {
    std::cout << "Hello, World!" << std::endl;
    return 0;
}
''',
    'go': '''
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
''',
    'html': '''
<!DOCTYPE html>
<html>
<body>

<h1>Hello, World!</h1>

</body>
</html>
''',
    'css': '''
body {
    background-color: lightblue;
}

h1 {
    color: navy;
    margin-left: 20px;
}
''',
    'json': '''
{
    "message": "Hello, World!"
}
''',
    'kotlin': '''
fun main() {
    println("Hello, World!")
}
''',
    'markdown': '''
# Hello, World!
This is a Markdown example.
''',
    'objectivec': '''
#import <Foundation/Foundation.h>

int main() {
    @autoreleasepool {
        NSLog(@"Hello, World!");
    }
    return 0;
}
''',
    'php': '''
<?php
echo "Hello, World!";
?>
''',
    'ruby': '''
puts "Hello, World!"
''',
    'rust': '''
fn main() {
    println!("Hello, World!");
}
''',
    'swift': '''
import Foundation

print("Hello, World!")
''',
    'typescript': '''
function greet(): void {
    console.log("Hello, World!");
}

greet();
''',
    'xml': '''
<message>
    <text>Hello, World!</text>
</message>
''',
    'yaml': '''
message: "Hello, World!"
''',
  };
}
