input = [-3 7 89 -12 7 99 167 67.29];
coeff = [0.1 0.4 0.4 0.1];
y = filter(coeff, 1, input);
disp(y);
