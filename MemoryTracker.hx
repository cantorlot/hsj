/**
 * 
 * @author axel@cunity.me
 *
 * All rights reserved
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 *   - Redistributions of source code must retain the above copyright
 *     notice, this list of conditions and the following disclaimer.
 *   - Redistributions in binary form must reproduce the above copyright
 *     notice, this list of conditions and the following disclaimer in the
 *     documentation and/or other materials provided with the distribution.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 */

import flash.utils.Dictionary;
import flash.utils.Timer;
import flash.events.TimerEvent;

class MemoryTracker {
    /// This is a facility to track the lifetime of specific objects
    static private var dict : Dictionary;
    static private var keys : Hash<Int>;
    static private var uniqueKeys : Hash<String>;
    static private var timer : Timer;
    static public var lastTrace : String;

    /// Call this with objects that you would like to track, and an ID toidentify it
    static public function track(obj : Dynamic, key : String) : Void {
        initTrackerIfNecessary();
        if (dict[obj] == key) {
            // OK, we are already tracking it
            return;
        }

        // We count the number of keys with this value so we can get uniqueids
        var count = keys.get(key);
        if (count == null) {
            count = 1;
        } else {
            count++;
        }
        keys.set(key, count);

        // Now we have a unique key
        var uniqueKey = key + " " + count;
        trace("Start tracking " + uniqueKey);
        uniqueKeys.set(uniqueKey, key);
        // And make the weak reference to the object
        dict[obj] = uniqueKey;
    }
    static function initTrackerIfNecessary() {
        if (dict == null) {
            // We use weak references as a trick to monitor lifetime of objects
            dict = new Dictionary(true);
            keys = new Hash<Int>();
            uniqueKeys = new Hash<String>();
            timer = new Timer(250);
            timer.addEventListener(TimerEvent.TIMER, onTimer);
            timer.start();
        }
    }
    static function onTimer(event : TimerEvent) : Void {
        var seenKeys : Hash<Int> = new Hash<Int>();
        var t : Array<Dynamic> = untyped __keys__(dict);
        for (k in t) {
            var v = dict[k];
            seenKeys.set(v, 0);
        }

        var releaseKeys : Array<String> = new Array<String>();
        for (k in uniqueKeys.keys()) {
            if (!seenKeys.exists(k)) {
                releaseKeys.push(k);
            }
        }
        if (releaseKeys.length > 0) {
            trace(releaseKeys.join(", ") + " has been garbage collected");
            for (k in releaseKeys) {
                var key = uniqueKeys.get(k);
                uniqueKeys.remove(k);
                var c = keys.get(key);
                --c;
                if (c == 0) {
                    keys.remove(key);
                    trace("No more objects of " + key + " remain");
                } else {
                    keys.set(key, c);
                }
            }
        }
    }
}
