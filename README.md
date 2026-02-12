# Project SHEREC Navigation

This repository provides an example of Aerostack2 navigation capabilities developed within the European-funded SHEREC project.

## Setup using Docker (Recommended)

Go to the root folder of the repository and run:

```bash
xhost + # this will enable gazebo visualization
docker compose up -d # use the -d for keep the container alive in background
```

With this there is a running instance of the container with this project mounted in ```/root/sherec_nav```.
Now you can run as much terminals as you need by running: 

```bash
docker exec -it as2_sherec_nav /bin/bash
```

> For stopping the container run ```xhost - ; docker compose down ``` command on the repo root folder. This will also remove the access to the XServer from the container.

## Native Setup (without docker)

> Work in progress...

## Launching the Navigation Example

```bash
./launch_as2.bash
```

Launch script will display three different simulation scenarios:

```bash
Choose simulation config file to open:
     1	sim_config/world_3d_lidar.json
     2	sim_config/world_depth_cam.json
     3	sim_config/world_planar_lidar.json
```

Curently, only **scenario 1** is ready to go.

### Interactive Navigation

> Work in progress...

### Mission (python) navigation

```bash
python mission_path_planner_test.py
```

## Troubleshooting

> Work in progress...

## Citation

If you use Aerostack2 in your research, please cite:

* M. Fernandez-Cortizas, M. Molina, P. Arias-Perez, R. Perez-Segui, D. Perez-Saura, and P. Campoy,  2023, ["Aerostack2: A software framework for developing multi-robot aerial systems"](https://arxiv.org/abs/2303.18237), ArXiv DOI 2303.18237.

<!-- ## License

[Your License Here] -->

<!-- ## Contributing

Contributions are welcome! Please see CONTRIBUTING.md for guidelines. -->

## Acknowledgments

This work has received funding from the European Union’s Horizon Europe research and innovation programme under Project No. HZ230070443 SHEREC — Safe, Healthy and Environmental Ship Recycling.