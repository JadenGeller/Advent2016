
split(0, List, [], List).
split(N, [X|List], [X|Init], Tail) :- M is N - 1, split(M, List, Init, Tail).

group(_, [], []).
group(N, List, [GroupedInit|GroupedRest]) :- split(N, List, GroupedInit, Rest), group(N, Rest, GroupedRest).

each(_, [], []).
each(N, [H|T], [H]) :- length(T, L), L < N - 1. 
each(N, List, [H|Rest]) :- split(N, List, [H|_], Tail), each(N, Tail, Rest).

input(InputNumbers) :- open('input.txt', read, InputFile),
                       read_string(InputFile, _, InputString),
                       split_string(InputString, " \n", " \n", InputList),
                       maplist(atom_number, InputList, InputNumbers).
		  
valid_triangle(A, B, C) :- A + B > C, A + C > B, B + C > A.

count_satisfying([], 0).
count_satisfying([H|T], N) :- count_satisfying(T, M), (apply(valid_triangle, H) -> N is M + 1; N is M).

part1(N) :- input(Input), group(3, Input, Triangles), count_satisfying(Triangles, N).
part2(N) :- input(Input), 
            each(3, Input, Left), 
            split(1, Input, _, Offset1Input), each(3, Offset1Input, Center), 
            split(2, Input, _, Offset2Input), each(3, Offset2Input, Right),
            append(Left, Center, Partial), append(Partial, Right, TransformedInput),
            group(3, TransformedInput, Triangles), count_satisfying(Triangles, N).
            