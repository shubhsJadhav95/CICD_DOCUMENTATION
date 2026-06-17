##### RDS in private subnet, can't reach from laptop
##### Added SSL to db.config.js
```
const { Sequelize } = require('sequelize');
require('dotenv').config();

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  process.env.DB_PASSWORD,
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    logging: false,
    dialectOptions: {
      ssl: {
        require: true,
        rejectUnauthorized: false
      }
    }
  }
);

module.exports = sequelize;
```


```
sudo apt update
sudo apt install postgresql-client -y

```
```
psql -h database-1.cc7immiow9w7.us-east-1.rds.amazonaws.com -U postgres -p
```
#### Created DB via psql -> neocare

#### Applied ConfigMap + Secret

```
 DB_HOST: "database-1.cc7immiow9w7.us-east-1.rds.amazonaws.com"
  DB_PORT: "5432"
  DB_NAME: "neocare"
  DB_USER: "postgres"
  ```

  ##### RECOMMENDED
  #### Added  10.0.0.0/16 RDS inbound rules -> Allows any IP in that range regardless of SG


  ##### FOR SECURITY IN PRODUCTION
  #### Added EKS node SG sg-0d881bff599f8490c to RDS inbound rules -> Only allows resources attached to that specific SG

