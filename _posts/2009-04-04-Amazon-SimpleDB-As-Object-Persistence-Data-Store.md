---
layout: post
title:  Using Amazon SimpleDB as an Object Persistence Data Store
date:   2009-04-04 10:21:00
tags:
- aws
- c sharp
- code
---

I hate relational databases!  In a high traffic scenario they become painful to scale.  Data segmentation, replication, asynchronous updates…you can only go so far.  Schema changes alone require site outages and careful planning.  That is why I was excited when Amazon announced their [SimpleDB service](http://www.satine.org/archives/2007/12/13/amazon-simpledb/).

#### Features
* High Availability
* Scales with you
* No need to worry about schema
* Has a free tier for low traffic uses

I am working on two social networking sites ([tool-assisted](http://www.tool-assisted.com), [beerpassport](http://beerpassport.com)) that I plan to use SDB for.  The basic idea is to have several cheap web servers talking to a pool of memcached instances that act as a caching mechanism for my object graph which is stored in SDB.  The first step towards implementing this solution is to come up with a way to persist objects into the SDB.

#### Object to be persisted
First lets look at the object I want to save to the database.  I want as little actual db code in this object as possible.

{% highlight csharp %}
{% raw %}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using ToolAssistedCom.Models;
using Amazon.SimpleDB.ORM;

namespace ToolAssistedCom.Models
{
    public class Platform
    {
        public string Description { get; set; }
        public List<String> Manufacturers { get; set; }
        public string Name { get; set; }
        public List<String> OnlineServices { get; set; }
        public string Predecessor { get; set; }
        public string Successor { get; set; }
        [SDB(IsKey = true)] public string UID { get; set; }

        /// <summary>
        /// Default constructor
        /// </summary>
        public Platform()
        {
            Description = "";
            UID = "";
            Name = "";
            Manufacturers = new List<string>();
            Predecessor = "";
            Successor = "";
            OnlineServices = new List<string>();
        }

    }
}
{% endraw %}
{% endhighlight %}

#### Base Class
Now I am going to define my base class.  I want this class to be generic enough to load any object from the database.  I have defined two methods called LoadOne and LoadMany which will be used to do this.  I have not implemented a save mechanism yet.

{% highlight csharp %}
{% raw %}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Amazon.SimpleDB;
using Amazon.SimpleDB.Model;
using System.Reflection;
using Attribute = Amazon.SimpleDB.Model.Attribute;

namespace Amazon.SimpleDB.ORM
{
    public abstract class SimpleDBObject
    {
        protected string _domainName = "";
        protected string _columns = "*";
        protected string _sort = "";
        protected string _accessKeyId = "YOURKEY";
        protected string _secretAccessKey = "SECRETKEY";
        protected AmazonSimpleDB _service = null;
        protected SelectRequest _request = null;
        protected object _prototype = null;

        protected void SetupClient()
        {
            _service = new AmazonSimpleDBClient(_accessKeyId, _secretAccessKey);
        }

        protected void CreateNewSelectRequest()
        {
            _service = new AmazonSimpleDBClient(_accessKeyId, _secretAccessKey);
            _request = new SelectRequest();
        }

        protected void SetValueFromResponse(ref object myobj, string name, string value)
        {
            // Include the type of the object
            System.Type type = myobj.GetType();


            // Walk the properties on this object
            System.Reflection.PropertyInfo[] pi = type.GetProperties();
            if (pi.Length > 0)
            {
                foreach (PropertyInfo p in pi)
                {

                    if (p.CanRead && p.CanWrite && p.Name.ToLower() == name.ToLower())
                    {
                        if (p.PropertyType == typeof(List<String>))
                        {
                            ((List<string>)p.GetValue(myobj, null)).Add(value);
                        }
                        else if (p.PropertyType == typeof(string))
                        {
                            p.SetValue(myobj, value, null);
                        }
                        else if (p.PropertyType == typeof(int))
                        {
                            p.SetValue(myobj, int.Parse(value), null);
                        }

                    }
                }
            }
        }//send SetValueFromResponse

        protected void LoadOneFromDB(string id)
        {
            SetupClient();
            CreateNewSelectRequest();
            _request.SelectExpression = "select " + _columns + " from " + _domainName + " where UID = '" + id + "'";
            if (!string.IsNullOrEmpty(_sort))
            {
                _request.SelectExpression += " order by " + _sort;
            }
            SelectResponse response = _service.Select(_request);

            if (response.IsSetSelectResult())
            {
                SelectResult result = response.SelectResult;
                List<Item> itemList = result.Item;
                foreach (Item item in itemList)
                {
                    if (item.IsSetName())
                    {
                    }
                    List<Attribute> attributeList = item.Attribute;
                    foreach (Attribute attribute in attributeList)
                    {

                        if (attribute.IsSetName() && attribute.IsSetValue())
                        {
                            SetValueFromResponse(ref _prototype, attribute.Name, attribute.Value);
                        }
                    }//end foreach attribute
                }//end for each item
            }//if issetseltresult
            else
            {
                throw new Exception("WTF M8");
            }
        }

        protected List<Object> LoadManyFromDB()
        {
            List<object> myList = new List<object>();
            SetupClient();
            CreateNewSelectRequest();
            _request.SelectExpression = "select " + _columns + " from " + _domainName;

            if (!string.IsNullOrEmpty(_sort))
            {
                _request.SelectExpression += " order by " + _sort;
            }
            SelectResponse response = _service.Select(_request);

            if (response.IsSetSelectResult())
            {
                SelectResult result = response.SelectResult;
                List<Item> itemList = result.Item;
                foreach (Item item in itemList)
                {
                    if (item.IsSetName())
                    {
                    }
                    object myobj = System.Activator.CreateInstance(_prototype.GetType());

                    List<Attribute> attributeList = item.Attribute;
                    foreach (Attribute attribute in attributeList)
                    {

                        if (attribute.IsSetName() && attribute.IsSetValue())
                        {
                            SetValueFromResponse(ref myobj, attribute.Name, attribute.Value);   
                        }
                    }//end foreach attribute
                    myList.Add(myobj);
                }//end for each item
            }//if issetseltresult
            else
            {
                throw new Exception("WTF M8");
            }
            return myList;
        }
    }
}
{% endraw %}
{% endhighlight %}

#### Glue Code
Finally here is the code that glues it together.

{% highlight csharp %}
{% raw %}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Amazon.SimpleDB.ORM;
using System.Reflection;

namespace ToolAssistedCom.Models
{
    public class SDBPlatform : SimpleDBObject, IPlatformRepository
    {
        public SDBPlatform()
        {
            _domainName = "Platform";
            _prototype = new Platform();

        }

        public Platform GetByUID(string id){
            LoadOneFromDB(id);
            return ((Platform)_prototype);
        }

        public void Add(Platform entity)
        {
            throw new NotImplementedException();
        }
        public void Remove(Platform entity)
        {
            throw new NotImplementedException();
        }

        public List<Platform> GetPlatforms()
        {
            List<Platform> temp = new List<Platform>();
            foreach (Platform item in LoadManyFromDB())
            {
                temp.Add(item);
            }
            return temp;
        }

        public void Save(Platform entity)
        {
            throw new NotImplementedException();
        }
    }

}
{% endraw %}
{% endhighlight %}

 I will release more details as I finish writing the code. Once the code is in a pretty good state I will throw it up on codeplex incase anyone else wants to use it (or improve it).
