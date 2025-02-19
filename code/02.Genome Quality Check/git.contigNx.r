# Load required libraries
library(ggplot2)
library(reshape2)

# Read the data from a CSV file
data <- read.csv("nx_values.csv")

# Convert data to long format for ggplot
data_long <- melt(data, id.vars = "x", variable.name = "Species", value.name = "Nx")

# Open a PDF device to save the plot
pdf("Nxcurve.pdf", width = 8, height = 6)

# Create the Nx curve plot
plot <- ggplot(data_long, aes(x = x, y = Nx, color = Species, group = Species)) +
  geom_line(size = 1) +
  labs(title = "Nx Curve",
       x = "x",
       y = "Sequence length (Mbp)") +
  theme_minimal() +
  theme(legend.title = element_blank(),
        plot.title = element_text(hjust = 0.5))

# Print the plot to the PDF
print(plot)

# Close the PDF device
dev.off()

