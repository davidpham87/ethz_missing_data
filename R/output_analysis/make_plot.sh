echo "Making plot for full dataset"
R CMD BATCH output_analysis_fulldataset.R &

echo "Making plot for partial dataset"
R CMD BATCH output_analysis_partialdataset.R &
