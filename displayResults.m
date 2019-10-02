function displayResults (psensitivity, pspecificity, p510sensitivity, p510specificity, dsensitivity, dspecificity, d510sensitivity, d510specificity)


f = figure;
t = uitable(f,'Position',[50 200 438 58]);
t.ColumnName = {'Prediction','Prediction 5/10','Detection','Detection 5/10'};
t.RowName = {'Sensitivity','Specificity'};

info=[psensitivity, p510sensitivity, dsensitivity, d510sensitivity; pspecificity, p510specificity, dspecificity,  d510specificity];

set(t,'Data',info);

end