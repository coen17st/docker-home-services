# mosquitto

### allow port set firewall rule
```
sudo ufw allow 1883/tcp
```

### Add new row in the passwordfile with username and password separated by a colon "username:password".
```
echo "<username>:<password>" | sudo tee passwordfile
```

### encrypt the passwords, go into container
```
mosquitto_passwd -U /mosquitto/config/passwordfile
```