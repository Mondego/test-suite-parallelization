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

package io.github.bucket4j.grid;

import io.github.bucket4j.EstimationProbe;
import io.github.bucket4j.serialization.DeserializationAdapter;
import io.github.bucket4j.serialization.SerializationAdapter;
import io.github.bucket4j.serialization.SerializationHandle;

import java.io.IOException;


public class EstimateAbilityToConsumeCommand implements GridCommand<EstimationProbe> {

    private static final long serialVersionUID = 1L;

    private long tokensToConsume;

    public static final SerializationHandle<EstimateAbilityToConsumeCommand> SERIALIZATION_HANDLE = new SerializationHandle<EstimateAbilityToConsumeCommand>() {
        @Override
        public <S> EstimateAbilityToConsumeCommand deserialize(DeserializationAdapter<S> adapter, S input) throws IOException {
            long tokensToConsume = adapter.readLong(input);

            return new EstimateAbilityToConsumeCommand(tokensToConsume);
        }

        @Override
        public <O> void serialize(SerializationAdapter<O> adapter, O output, EstimateAbilityToConsumeCommand command) throws IOException {
            adapter.writeLong(output, command.tokensToConsume);
        }

        @Override
        public int getTypeId() {
            return 10;
        }

        @Override
        public Class<EstimateAbilityToConsumeCommand> getSerializedType() {
            return EstimateAbilityToConsumeCommand.class;
        }

    };

    public EstimateAbilityToConsumeCommand(long tokensToEstimate) {
        this.tokensToConsume = tokensToEstimate;
    }

    @Override
    public EstimationProbe execute(GridBucketState state, long currentTimeNanos) {
        state.refillAllBandwidth(currentTimeNanos);
        long availableToConsume = state.getAvailableTokens();
        if (tokensToConsume <= availableToConsume) {
            return EstimationProbe.canBeConsumed(availableToConsume);
        } else {
            long nanosToWaitForRefill = state.calculateDelayNanosAfterWillBePossibleToConsume(tokensToConsume, currentTimeNanos);
            return EstimationProbe.canNotBeConsumed(availableToConsume, nanosToWaitForRefill);
        }
    }

    @Override
    public boolean isBucketStateModified() {
        return false;
    }

    public long getTokensToConsume() {
        return tokensToConsume;
    }

}
