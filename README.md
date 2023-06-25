# Project Introduction
The substation transmits high-voltage power to different areas through transmission lines, and then distributes the power to end users through the distribution network to ensure the stability and reliability of the power supply. This project is used to rate the substation by calculating its **power coverage**, determining the power scale and service scope it can provide.

# Implementation Ideas
Obtain the corresponding line through the high-voltage transmission tower of the substation, find all descendants of the line, and then process the power towers contained in all lines. Each tower has coordinate points, construct each adjacent tower into a line and calculate the distance between the adjacent towers. Finally, thread all lines in series to identify all possible scenarios and calculate the **longest line**.

# Core Technical Points
1. Analyzing and constructing a data structure that supports PostgreSQL tree queries based on the original data structure.
2. Obtaining Results through PostgreSQL Tree Queries.
3. Calculate distance through PostGIS correlation functions.

# Business Process
1. Obtain all descendant lines of the corresponding line in the substation.
2. Initialize the required data structure based on the obtained circuit.
3. Processing s_ Point e_ Point hook association relationship.
4. Obtain final results through tree queries.

This project implements the core business logic for substation rating for backend services to call.
