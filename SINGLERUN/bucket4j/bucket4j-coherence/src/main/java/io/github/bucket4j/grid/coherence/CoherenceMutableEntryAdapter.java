/*-
 * ========================LICENSE_START=================================
 * Bucket4j
 * %%
 * Copyright (C) 2015 - 2020 Vladimir Bukhtoyarov
 * %%
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * =========================LICENSE_END==================================
 */

package io.github.bucket4j.grid.coherence;

import com.tangosol.util.InvocableMap;
import io.github.bucket4j.grid.GridBucketState;

import java.io.Serializable;
import java.util.Map;
import javax.cache.processor.MutableEntry;


class CoherenceMutableEntryAdapter<K extends Serializable> implements MutableEntry<K, GridBucketState> {

    private final Map.Entry<K, GridBucketState> entry;

    public CoherenceMutableEntryAdapter(InvocableMap.Entry<K, GridBucketState> entry) {
        this.entry = entry;
    }

    @Override
    public boolean exists() {
        return entry.getValue() != null;
    }

    @Override
    public void remove() {
        entry.setValue(null);
    }

    @Override
    public void setValue(GridBucketState value) {
        entry.setValue(value);
    }

    @Override
    public K getKey() {
        return entry.getKey();
    }

    @Override
    public GridBucketState getValue() {
        return entry.getValue();
    }

    @Override
    public <T> T unwrap(Class<T> clazz) {
        throw new UnsupportedOperationException();
    }

}
