# Oracle Coherence integration
Before use ```bucket4j-coherence``` module please read [bucket4j-jcache documentation](jcache-usage.md),
because ```bucket4j-coherence``` is just a follow-up of ```bucket4j-jcache```.

**Question:** Bucket4j already supports JCache since version ```1.2```. Why it was needed to introduce direct support for ```Oracle Coherence```?  
**Answer:** Because [JCache API (JSR 107)](https://www.jcp.org/en/jsr/detail?id=107) does not specify asynchronous API,
developing the dedicated module ```bucket4j-coherence``` was the only way to provide asynchrony for users who use ```Bucket4j``` and ```Oracle Coherence``` together.

**Question:** Should I migrate from ```bucket4j-jcache``` to ```bucketj-coherence``` If I do not need in asynchronous API?  
**Answer:** No, you should not migrate to ```bucketj-coherence``` in this case.

## Dependencies
To use ```bucket4j-coherence``` extension you need to add following dependency:
```xml
<dependency>
    <groupId>com.github.vladimir-bukhtoyarov</groupId>
    <artifactId>bucket4j-coherence</artifactId>
    <version>${bucket4j.version}</version>
</dependency>
```

## Example of Bucket instantiation
```java
com.tangosol.net.NamedCache<K, GridBucketState> cache = ...;
...

Bucket bucket = Bucket4j.extension(Coherence.class).builder()
                   .addLimit(Bandwidth.simple(1_000, Duration.ofMinutes(1)))
                   .build(cache, key, RecoveryStrategy.RECONSTRUCT);
```

## Example of ProxyManager instantiation
```java
com.tangosol.net.NamedCache<K, GridBucketState> cache = ...;
...

ProxyManager proxyManager = Bucket4j.extension(Coherence.class).proxyManagerForCache(cache);
```

## Configuring POF serialization for Bucket4j library classes
If you configure nothing, then by default Java serialization will be used for serialization Bucket4j library classes. Java serialization can be rather slow and should be avoided in general.
```Bucket4j``` provides [custom POF serializers](https://docs.oracle.com/cd/E24290_01/coh.371/e22837/api_pof.htm#COHDG1363) for all library classes that could be transferred over network.  
To let Coherence know about POF serializers you should register three serializers in the POF configuration config file: 
* ```CoherenceEntryProcessorAdapterPofSerializer``` for class ```CoherenceEntryProcessorAdapter```
* ```GridBucketStatePofSerializer``` for class ```GridBucketState```
* ```CommandResultPofSerializer``` for class ```CommandResult```

*Example of POF serialization:*
```xml
<pof-config xmlns="http://xmlns.oracle.com/coherence/coherence-pof-config"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://xmlns.oracle.com/coherence/coherence-pof-config coherence-pof-config.xsd">

    <user-type-list>
        <!-- Include default Coherence types -->
        <include>coherence-pof-config.xml</include>

        <!-- Define serializers for Bucket4j classes -->
        <user-type>
            <type-id>1001</type-id>
            <class-name>io.github.bucket4j.grid.coherence.CoherenceEntryProcessorAdapter</class-name>
            <serializer>
                <class-name>io.github.bucket4j.grid.coherence.pof.CoherenceEntryProcessorAdapterPofSerializer</class-name>
            </serializer>
        </user-type>
        <user-type>
            <type-id>1002</type-id>
            <class-name>io.github.bucket4j.grid.GridBucketState</class-name>
            <serializer>
                <class-name>io.github.bucket4j.grid.coherence.pof.GridBucketStatePofSerializer</class-name>
            </serializer>
        </user-type>
        <user-type>
            <type-id>1003</type-id>
            <class-name>io.github.bucket4j.grid.CommandResult</class-name>
            <serializer>
                <class-name>io.github.bucket4j.grid.coherence.pof.CommandResultPofSerializer</class-name>
            </serializer>
        </user-type>
    </user-type-list>
</pof-config>
```
Double check with [official Oracle Coherence documentation](https://docs.oracle.com/cd/E24290_01/coh.371/e22837/api_pof.htm#COHDG5182) in case of any questions related to ```Portable Object Format```.
