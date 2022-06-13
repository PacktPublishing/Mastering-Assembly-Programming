# Mastering Assembly Programming

<a href="https://www.packtpub.com/application-development/mastering-assembly-programming?utm_source=github&utm_medium=repository&utm_campaign=9781787287488"><img src="https://d1ldz4te4covpm.cloudfront.net/sites/default/files/imagecache/ppv4_main_book_cover/B07085.png" alt="Mastering Assembly Programming" height="256px" align="right"></a>

This is the code repository for [Mastering Assembly Programming](https://www.packtpub.com/application-development/mastering-assembly-programming?utm_source=github&utm_medium=repository&utm_campaign=9781787287488), published by Packt.

**From instruction set to kernel module with Intel processor**

## What is this book about?
The Assembly language is the lowest level human readable programming language on any platform. Knowing the way things are on the Assembly level will help developers design their code in a much more elegant and efficient way. It may be produced by compiling source code from a high-level programming language (such as C/C++) but can also be written from scratch. Assembly code can be converted to machine code using an assembler.

This book covers the following exciting features: 
* Obtain deeper understanding of the underlying platform
* Understand binary arithmetic and logic operations
* Create elegant and efficient code in Assembly language
* Understand how to link Assembly code to outer world
* Obtain in-depth understanding of relevant internal mechanisms of Intel CPU

If you feel this book is for you, get your [copy](https://www.amazon.com/dp/1787287483) today!

<a href="https://www.packtpub.com/?utm_source=github&utm_medium=banner&utm_campaign=GitHubBanner"><img src="https://raw.githubusercontent.com/PacktPublishing/GitHub/master/GitHub.png" alt="https://www.packtpub.com/" border="5" /></a>

## Instructions and Navigations
All of the code is organized into folders.

The code will look like the following:
```
fld [radius]   ; Load radius to ST0
               ; ST0 <== 0.2345
fldpi          ; Load PI to ST0
               ; ST1 <== ST0
               ; ST0 <== 3.1415926
fmulp          ; Multiply (ST0 * ST1) and pop
               ; ST0 = 0.7367034
fadd st0, st0  ; * 2
               ; ST0 = 1.4734069
fstp [result]  ; Store result
               ; result <== ST0
```

**Following is what you need for this book:**
This book is for developers who would like to learn about Assembly language. Prior programming knowledge of C and C++ is assumed.

With the following software and hardware list you can run all code files present in the book (Chapter 1-11).

### Software and Hardware List

| Chapter  | Software required                   | OS required                        |
| -------- | ------------------------------------| -----------------------------------|
| 1-11     | C and C++                           | Windows and Linux (Any) |



## Get to Know the Author
**Alexey Lyashko**
is an Assembly language addict, independent software reverse engineer, and consultant. At the very beginning of his career, when he was a malware researcher at Aladdin Knowledge Systems, he invented and developed a generic code recognition method known as HOFA™. After spending a few years in the anti-malware industry and gaining sufficient experience in low-level development and reverse engineering, Alexey switched to content protection and worked as a reverse engineering consultant with Irdeto’s BD+ department, actively participating in content protection technology development. 
Since 2013, he has worked with several software development companies providing reverse engineering and low-level software development consultancy.



### Suggestions and Feedback
[Click here](https://docs.google.com/forms/d/e/1FAIpQLSdy7dATC6QmEL81FIUuymZ0Wy9vH1jHkvpY57OiMeKGqib_Ow/viewform) if you have any feedback or suggestions.
