#### Overview
When we do nginx we have to ensure that all servers are running at their respective ports i.e 5173 for the front-end and 3000 for the backend. Then we prepare the file to route incoming the traffic to one of these servers using a specific path or location, meaning i.e `/` can mean front-end request and that will have to re-routed to the front-end server, and `/api/` that will do the same thing but for the back-end server. You can view the nginx configuration file.

#### Setup
After deploying the a cloud virtual machine, then will require to install nginx and the other servers dependencies and ensure they are running properly. Next once nginx is installed, we can move to copying the `nginx.conf` file to the sites-available location and creating a link to `sites-enabled` location.

Before you do anything ensure deleting default files from both directories `/etc/nginx/sites-enabled` and `/etc/nginx/sites-available`.

The following command is used to copying the file.
```bash
cp nginx/nginx.conf /etc/nginx/sites-available/
```

Next will create a link

```bash
sudo ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/nginx.conf
```

You can asure the link is created at the following path

```bash
ls -lh /etc/nginx/sites-enabled/
```

#### Start
Next we need to start the nginx server and ensure everything is running correctly.

To start and enable nginx on the system

```bash
sudo systemctl start nginx
sudo systemctl enable nginx
```

Sometimes nginx requires restart, just execute the following command

```bash
sudo systemctl restart nginx
```

###### Important
We also need to validate the configuration file so the following command is used for validating

```bash
sudo nginx -t
```

After validating, we need to start the nginx to take effect.

```bash
sudo systemctl restart nginx
```

Here is a great documentation for [nginx](https://www.freecodecamp.org/news/the-nginx-handbook/)

